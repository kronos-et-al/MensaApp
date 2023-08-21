use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};
use futures::future::join_all;
use mensa_app_backend::{layer::data::database::factory::DataAccessFactory, startup::config::ConfigReader, interface::persistent_data::RequestDataAccess, util::{Date, Uuid}};

fn bench(c: &mut Criterion) {
    let runtime = tokio::runtime::Runtime::new().unwrap();

    let cfg = ConfigReader::default();
    let factory = 
    runtime.block_on( async {
        DataAccessFactory::new(cfg.read_database_info().unwrap(), false).await.unwrap()    
    });
    let request = factory.get_request_data_access();

    let line_id = Uuid::try_from("cf1992cd-ccfa-4a86-9800-7c9d41dfff52").unwrap();
    let date = Date::from_ymd_opt(2023, 08, 21).unwrap();

    c.bench_function("database meals", |b| b.to_async(&runtime).iter(|| async { 
        request.get_meals(line_id, date).await.unwrap();
     }));

}

criterion_group!(name = group; config = Criterion::default().sample_size(50); targets = bench);
criterion_main!(group);
