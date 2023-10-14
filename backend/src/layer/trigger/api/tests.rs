#![cfg(test)]
#![allow(clippy::unwrap_used)]

use std::fs::File;
use std::io::Write;

use super::auth::AuthInfo;
use crate::layer::trigger::api::auth::AuthFailReason;
use crate::layer::trigger::api::mutation::MutationRoot;
use crate::layer::trigger::api::query::QueryRoot;
use crate::layer::trigger::api::server::construct_schema;
use crate::layer::trigger::api::util::{CommandBox, DataBox};
use crate::util::Uuid;
use async_graphql::{EmptySubscription, Request, Schema, UploadValue, Variables};
use serde_json::json;
use sha2::{Digest, Sha512};
use tempfile::tempdir;

use super::mock::{CommandMock, RequestDatabaseMock};
use base64::engine::Engine;

async fn test_gql_request(request: &'static str) {
    let request = Request::from(request).data(AuthInfo {
        client_id: Some(Uuid::default()),
        api_ident: String::new(),
        authenticated: Ok(()),
        hash: String::new(),
    });

    let schema = construct_schema(RequestDatabaseMock, CommandMock);
    let response = schema.execute(request).await;
    assert!(response.is_ok(), "request returned {:?}", response.errors);
}

// ---------------- mutations --------------------

#[tokio::test]
async fn test_add_image() {
    let dir = tempdir().unwrap();
    let mut path = dir.path().to_owned();
    let filename = "test.jpg";
    path.push(filename);
    let mut file = File::create(&path).unwrap();

    let image = include_bytes!("../../logic/api_command/tests/test.jpg");
    file.write_all(image).unwrap();
    let file = File::open(&path).unwrap();

    let hash = Sha512::new().chain_update(image).finalize().to_vec();
    let hash_base64 = base64::prelude::BASE64_STANDARD.encode(hash);

    let request = r#"
        mutation UploadFile($imageFile: Upload!, $hash: String!) {
            addImage(mealId:"1d75d380-cf07-4edb-9046-a2d981bc219d", image: $imageFile, hash: $hash)
        }
    "#;
    let mut request = Request::from(request)
        .data(AuthInfo {
            client_id: Some(Uuid::default()),
            api_ident: String::new(),
            authenticated: Ok(()),
            hash: String::new(),
        })
        .variables(Variables::from_json(json!( {
          "hash": hash_base64,
          "imageFile": ""
        })));
    request.set_upload(
        "variables.imageFile",
        UploadValue {
            filename: filename.into(),
            content_type: Some("image/jpeg".into()),
            content: file,
        },
    );

    let schema = construct_schema(RequestDatabaseMock, CommandMock);
    let response = schema.execute(request).await;
    assert!(response.is_ok(), "request returned {:?}", response.errors);
}

#[tokio::test]
async fn test_set_rating() {
    let request = r#"
    mutation {
        setRating(mealId: "00000000-0000-0000-0000-000000000000", rating:2)
        
    }   
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_image_votes() {
    let request = r#"
        mutation {
            addUpvote(imageId:"1d75d380-cf07-4edb-9046-a2d981bc219d")
            addDownvote(imageId:"1d75d380-cf07-4edb-9046-a2d981bc219d")
            removeUpvote(imageId:"1d75d380-cf07-4edb-9046-a2d981bc219d")
            removeDownvote(imageId:"1d75d380-cf07-4edb-9046-a2d981bc219d")
        }    
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_report_image() {
    let request = r#"
        mutation {
            reportImage(imageId:"1d75d380-cf07-4edb-9046-a2d981bc219d", reason:OFFENSIVE)
        }    
    "#;
    test_gql_request(request).await;
}

// ---------------------- queries -----------------------

#[tokio::test]
async fn test_api_version() {
    let request = r#"
        {
            apiVersion
        } 
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_complete_request() {
    let request = {
        r#"
    {
        getCanteens {
          id
          name
          lines {
            id
            name
            canteen {
              name
            }
            meals(date: "2000-01-01") {
              id
              name
              mealType
              ratings {
                averageRating
                ratingsCount
                personalRating
              }
              price {
                student
                employee
                guest
                pupil
              }
              statistics {
                lastServed
                nextServed
                frequency
                new
              }
              allergens
              additives
              images {
                id
                url
                rank
                upvotes
                downvotes
                personalUpvote
                personalDownvote
              }
              sides{
                id
                name
                price {
                    student
                    employee
                    guest
                    pupil
                  }
                allergens
                additives
                mealType
              }
              line {
                id
              }
            }
          }
        }
      }
      
    "#
    };
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_frondend_query() {
    let request = {
        r#"
query GetMealPlanForDay() {
    getCanteens {
        ...mealPlan
    }
}


fragment canteen on Canteen {
    id
    name
}

fragment mealPlan on Canteen {
    lines {
        id
        name
        canteen {
            ...canteen
        }
        meals(date: "2022-09-10") {
            ...mealInfo
        }
    }
}

fragment mealInfo on Meal {
    id
    name
    mealType
    price {
        ...price
    }
    allergens
    additives
    statistics {
        lastServed
        nextServed
        frequency
        new
    }
    ratings {
        averageRating
        personalRating
        ratingsCount
    }
    images {
        id
        url
        rank
        personalDownvote
        personalUpvote
        downvotes
        upvotes
    }
    sides {
        id
        name
        additives
        allergens
        price {
            ...price
        }
        mealType
    }
}

fragment price on Price {
    employee
    guest
    pupil
    student
}
"#
    };

    test_gql_request(request).await;
}

#[tokio::test]
async fn test_get_specific_canteen() {
    let request = r#"
    {
        getCanteen(canteenId: "1d75d380-cf07-4edb-9046-a2d981bc219d") {
          id
        }
      }
      
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_get_specific_meal() {
    let request = r#"
    {
        getMeal(
          mealId: "1d75d380-cf07-4edb-9046-a2d981bc219d"
          lineId: "00000000-0000-0000-0000-000000000000"
          date: "2000-01-01"
        ) {
          id
        }
      }
      
      
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_get_auth_info_empty() {
    let request = r#"
    {
        getMyAuth {
          clientId
          apiIdent
          hash
        }
      }
      
      
      
    "#;
    let request = Request::from(request).data(AuthInfo {
        client_id: None,
        api_ident: String::new(),
        authenticated: Err(AuthFailReason::MissingApiIdentOrHash),
        hash: String::new(),
    });

    let schema = construct_schema(RequestDatabaseMock, CommandMock);
    let response = schema.execute(request).await;
    assert!(response.is_ok(), "request returned {:?}", response.errors);
}

#[tokio::test]
async fn test_recursive_line_canteen_ok() {
    let request = r#"
    {
      getCanteens {
        lines {
          canteen {
            lines {
              id
            }
          }
        }
      }
    }
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_recursive_meal_line_ok() {
    let request = r#"
    {
      getCanteens {
        lines {
          meals(date: "2000-01-01") {
            line {
              meals(date: "2000-01-01") {
                id
              }
            }
          }

        }
      }
    }
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
async fn test_get_auth_info() {
    let request = r#"
    {
        getMyAuth {
          clientId
          apiIdent
          hash
          authenticated
          authError
        }
      }
    "#;

    let auth_info: AuthInfo = AuthInfo {
        client_id: Some(Uuid::try_from("1d75d380-cf07-4edb-9046-a2d981bc219d").unwrap()),
        api_ident: "abc".into(),
        hash: "123".into(),
        authenticated: Ok(()),
    };

    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(Box::new(RequestDatabaseMock) as DataBox)
        .data(Box::new(CommandMock) as CommandBox)
        .data(auth_info)
        .finish();
    let response = schema.execute(request).await;
    assert!(response.is_ok(), "request returned {:?}", response.errors);

    let response_str = response.data.to_string();
    assert!(
        response_str.contains(r#"clientId: "1d75d380-cf07-4edb-9046-a2d981bc219d""#),
        "client_id not present in {response_str}"
    );
    assert!(
        response_str.contains(r#"apiIdent: "abc""#),
        "api_ident not present in {response_str}"
    );
    assert!(
        response_str.contains(r#"hash: "123""#),
        "hash not present in {response_str}"
    );
}
