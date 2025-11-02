use fjall::{Config, Keyspace, Partition, PartitionCreateOptions};
use magnus::{
    block::Yield, function, gc::register_mark_object, method, prelude::*, value::Lazy, Error,
    ExceptionClass, RModule, Ruby,
};

static FJALL_ERROR: Lazy<ExceptionClass> = Lazy::new(|ruby| {
    let ex = ruby
        .class_object()
        .const_get::<_, RModule>("FjallRuby")
        .unwrap()
        .const_get("Error")
        .unwrap();
    // ensure `ex` is never garbage collected (e.g. if constant is
    // redefined) and also not moved under compacting GC.
    register_mark_object(ex);
    ex
});

#[magnus::wrap(class = "FjallRuby::Keyspace", free_immediately, size)]
struct FjallKeyspace {
    keyspace: Keyspace,
}

impl FjallKeyspace {
    fn new(path: String) -> Self {
        let keyspace = Config::new(path).open().unwrap();
        FjallKeyspace { keyspace }
    }

    fn open_partition(ruby: &Ruby, rb_self: &Self, name: String) -> Result<FjallPartition, Error> {
        rb_self
            .keyspace
            .open_partition(&name, PartitionCreateOptions::default())
            .map(|partition| FjallPartition::new(partition))
            .map_err(|e| Error::new(ruby.get_inner(&FJALL_ERROR), e.to_string()))
    }

    fn persist(ruby: &Ruby, rb_self: &Self) -> Result<(), Error> {
        rb_self
            .keyspace
            .persist(fjall::PersistMode::SyncAll)
            .map_err(|e| Error::new(ruby.get_inner(&FJALL_ERROR), e.to_string()))
    }
}

#[magnus::wrap(class = "FjallRuby::Partition", free_immediately, size)]
struct FjallPartition {
    partition: Partition,
}

impl FjallPartition {
    fn new(partition: Partition) -> Self {
        FjallPartition { partition }
    }

    fn insert(ruby: &Ruby, rb_self: &Self, key: String, value: String) -> Result<(), Error> {
        rb_self.partition.insert(key, value).map_err(|e| {
            Error::new(
                ruby.get_inner(&FJALL_ERROR),
                format!("Failed to insert into partition: {}", e),
            )
        })
    }

    fn get(ruby: &Ruby, rb_self: &Self, key: String) -> Result<Option<String>, Error> {
        rb_self
            .partition
            .get(key)
            .map(|value| value.map(|inner| inner.escape_ascii().to_string()))
            .map_err(|e| {
                Error::new(
                    ruby.get_inner(&FJALL_ERROR),
                    format!("Failed to get from partition: {}", e),
                )
            })
    }

    fn remove(ruby: &Ruby, rb_self: &Self, key: String) -> Result<(), Error> {
        rb_self.partition.remove(key).map_err(|e| {
            Error::new(
                ruby.get_inner(&FJALL_ERROR),
                format!("Failed to remove from partition: {}", e),
            )
        })
    }

    fn name(&self) -> String {
        self.partition.name.to_string()
    }

    fn each_key(&self) -> Yield<impl Iterator<Item = Option<String>>> {
        Yield::Iter(
            self.partition
                .keys()
                .map(|key| key.ok().map(|inner| inner.escape_ascii().to_string())),
        )
    }

    fn prefix(&self, prefix: String) -> Yield<impl Iterator<Item = Option<(String, String)>>> {
        Yield::Iter(self.partition.prefix(prefix).map(|pair| {
            pair.ok().map(|(key, value)| {
                (
                    key.escape_ascii().to_string(),
                    value.escape_ascii().to_string(),
                )
            })
        }))
    }

    fn contains_key(ruby: &Ruby, rb_self: &Self, key: String) -> Result<bool, Error> {
        rb_self.partition.contains_key(key).map_err(|e| {
            Error::new(
                ruby.get_inner(&FJALL_ERROR),
                format!("Failed to check key existence: {}", e),
            )
        })
    }
}

#[magnus::init]
fn init(ruby: &Ruby) -> Result<(), Error> {
    let gem_module = ruby.define_module("FjallRuby")?;
    let keyspace_class = gem_module.define_class("Keyspace", ruby.class_object())?;
    keyspace_class.define_singleton_method("new", function!(FjallKeyspace::new, 1))?;
    keyspace_class.define_method("open_partition", method!(FjallKeyspace::open_partition, 1))?;
    keyspace_class.define_method("persist", method!(FjallKeyspace::persist, 0))?;

    let partition_class = gem_module.define_class("Partition", ruby.class_object())?;
    partition_class.define_method("insert", method!(FjallPartition::insert, 2))?;
    partition_class.define_method("get", method!(FjallPartition::get, 1))?;
    partition_class.define_method("remove", method!(FjallPartition::remove, 1))?;
    partition_class.define_method("name", method!(FjallPartition::name, 0))?;
    partition_class.define_method("each_key", method!(FjallPartition::each_key, 0))?;
    partition_class.define_method("prefix", method!(FjallPartition::prefix, 1))?;
    partition_class.define_method("contains_key", method!(FjallPartition::contains_key, 1))?;

    Ok(())
}
