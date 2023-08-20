use std::mem;

use chrono::{Duration, NaiveDate};
use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion, Throughput};
use futures::future::join_all;
use gql_client::Client;
use lazy_static::lazy_static;
use serde::{Deserialize, Serialize};

#[derive(Deserialize, Debug)]
struct Data {}

#[derive(Serialize, Clone)]
struct Vars {
    date: NaiveDate,
}

lazy_static! {
    static ref CLIENT: Client = Client::new("https://api.mensa-ka.de");
}

fn bench(c: &mut Criterion) {
    let _ = &CLIENT;
    let query = include_str!("query.gql");

    let base_date = NaiveDate::from_ymd_opt(2023, 8, 21).unwrap();

    let runtime = tokio::runtime::Runtime::new().unwrap();

    c.bench_function("meal", |b| {
        b.to_async(&runtime).iter(|| async {
            CLIENT
                .query_with_vars::<Data, Vars>(query, Vars { date: base_date })
                .await
                .unwrap();
        });
    });

    c.bench_function("week meal", |b| {
        b.to_async(&runtime).iter(|| async {
            join_all((0..5).map(|offset| {
                CLIENT.query_with_vars::<Data, Vars>(
                    query,
                    Vars {
                        date: base_date + Duration::days(offset),
                    },
                )
            }))
            .await
            .into_iter()
            .collect::<Result<Vec<_>, _>>()
            .unwrap();
        });
    });

    c.bench_function("all meal", |b| {
        b.to_async(&runtime).iter(|| async {
            join_all((0..7 * 3).map(|offset| {
                CLIENT.query_with_vars::<Data, Vars>(
                    query,
                    Vars {
                        date: base_date + Duration::days(offset),
                    },
                )
            }))
            .await
            .into_iter()
            .collect::<Result<Vec<_>, _>>()
            .unwrap();
        });
    });

    c.bench_function("all meal paralell", |b| {
        b.to_async(&runtime).iter(|| async {
            join_all(
                (0..7 * 3)
                    .map(move |offset| {
                        tokio::spawn(CLIENT.query_with_vars::<Data, Vars>(
                            query,
                            Vars {
                                date: base_date + Duration::days(offset),
                            },
                        ))
                    })
                    .map(|h| async { h.await.unwrap() }),
            )
            .await;
        });
    });

    c.bench_function("2 all meal paralell", |b| {
        b.to_async(&runtime).iter(|| async {
            join_all((0..2).map(|_| {
                let fut = join_all((0..7 * 3).map(|offset| {
                    CLIENT.query_with_vars::<Data, Vars>(
                        query,
                        Vars {
                            date: base_date + Duration::days(offset),
                        },
                    )
                }));

                tokio::spawn(fut)
            }))
            .await
            .into_iter()
            .flat_map(|v| v.unwrap().into_iter())
            .map(|u| u.unwrap().unwrap())
            .for_each(mem::drop);
        });
    });

    c.bench_function("100", |b| {
        b.to_async(&runtime).iter(|| async {
            join_all(
                (0..100)
                    .map(|_| CLIENT.query_with_vars::<Data, Vars>(query, Vars { date: base_date })),
            )
            .await
            .into_iter()
            .map(|v| v.unwrap().unwrap())
            .for_each(mem::drop);
        });
    });

    let mut group = c.benchmark_group("many_requests");
    for size in [1, 5, 10, 20].iter() {
        group.throughput(Throughput::Elements(*size as u64));
        group.bench_with_input(BenchmarkId::from_parameter(size), size, |b, &size| {
            b.to_async(&runtime).iter(|| async {
                join_all((0..size).map(|_| {
                    CLIENT.query_with_vars::<Data, Vars>(query, Vars { date: base_date })
                }))
                .await
                .into_iter()
                .map(|v| v.unwrap().unwrap())
                .for_each(mem::drop);
            });
        });
    }
    group.finish();
}

criterion_group!(name = group; config = Criterion::default().sample_size(50); targets = bench);
criterion_main!(group);
