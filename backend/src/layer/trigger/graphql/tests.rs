#![cfg(test)]
#![allow(clippy::unwrap_used)]

use async_graphql::{EmptySubscription, Schema};

use crate::layer::trigger::graphql::mutation::MutationRoot;
use crate::layer::trigger::graphql::query::QueryRoot;
use crate::layer::trigger::graphql::server::construct_schema;
use crate::layer::trigger::graphql::util::{AuthHeader, CommandBox, DataBox};

use super::mock::{CommandMock, RequestDatabaseMock};

async fn test_gql_request(request: &'static str) {
    let schema = construct_schema(RequestDatabaseMock, CommandMock);
    let response = schema.execute(request).await;
    assert!(response.is_ok(), "request returned {:?}", response.errors);
}

// ---------------- mutations --------------------

#[tokio::test]
async fn test_add_image() {
    let request = r#"
        mutation {
            addImage(mealId:"1d75d380-cf07-4edb-9046-a2d981bc219d", imageUrl:"")
        }    
    "#;
    test_gql_request(request).await;
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
async fn test_get_auth_info_null() {
    let request = r#"
    {
        getMyAuth {
          clientId
          apiIdent
          hash
        }
      }
      
      
      
    "#;
    test_gql_request(request).await;
}

#[tokio::test]
#[should_panic = "Query is too complex."]
async fn test_recursive_line_canteen_panic() {
    let request = r#"
    {
      getCanteens {
        lines {
          canteen {
            lines {
              canteen {id}
            }
          }
        }
      }
    }
    "#;
    test_gql_request(request).await;
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
#[should_panic = "Query is too complex."]
async fn test_recursive_meal_line_panic() {
    let request = r#"
    {
      getCanteens {
        lines {
          meals(date: "2000-01-01") {
            line {
              meals(date: "2000-01-01") {
                line {
                  id
                }
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
async fn test_get_auth_info_correct() {
    let request = r#"
    {
        getMyAuth {
          clientId
          apiIdent
          hash
        }
      }
      
      
      
    "#;
    let schema = Schema::build(QueryRoot, MutationRoot, EmptySubscription)
        .data(Box::new(RequestDatabaseMock) as DataBox)
        .data(Box::new(CommandMock) as CommandBox)
        .data(
            "Mensa MWQ3NWQzODAtY2YwNy00ZWRiLTkwNDYtYTJkOTgxYmMyMTlkOmFiYzoxMjM=".to_string()
                as AuthHeader,
        )
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
