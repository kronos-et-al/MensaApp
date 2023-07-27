use async_trait::async_trait;
use sqlx::{Pool, Postgres};

use crate::{
    interface::persistent_data::{model::Image, ImageReviewDataAccess, Result},
    null_error,
    util::{Date, Uuid},
};

pub struct PersistentImageReviewData {
    pub(super) pool: Pool<Postgres>,
}

#[async_trait]
#[allow(clippy::missing_panics_doc)] // necessary because sqlx macro sometimes create unreachable panics?
impl ImageReviewDataAccess for PersistentImageReviewData {
    async fn get_n_images_by_rank_date(&self, n: u32, date: Date) -> Result<Vec<Image>> {
        sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date
            FROM image_detail 
            WHERE food_id in (SELECT food_id from food_plan WHERE serve_date = $1)
            ORDER BY rank DESC, image_id
            LIMIT $2
            ",
            date,
            i64::from(n)
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|r| {
            Ok(Image {
                id: null_error!(r.image_id),
                url: null_error!(r.url),
                image_hoster_id: null_error!(r.hoster_id),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                rank: null_error!(r.rank),
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn get_n_images_next_week_by_rank_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date
            FROM image_detail 
            WHERE food_id in (SELECT food_id from food_plan WHERE serve_date >= CURRENT_DATE AND serve_date < CURRENT_DATE + 7)
            AND last_verified_date < CURRENT_DATE - 7
            ORDER BY rank DESC, image_id
            LIMIT $1
            ",
            i64::from(n)
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|r| {
            Ok(Image {
                id: null_error!(r.image_id),
                url: null_error!(r.url),
                image_hoster_id: null_error!(r.hoster_id),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                rank: null_error!(r.rank),
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn get_n_images_by_last_checked_not_checked_last_week(
        &self,
        n: u32,
    ) -> Result<Vec<Image>> {
        sqlx::query!(
            "
            SELECT image_id, rank, id as hoster_id, url, upvotes, downvotes, 
                approved, report_count, link_date
            FROM image_detail
            WHERE last_verified_date < CURRENT_DATE - 7
            ORDER BY last_verified_date, image_id
            LIMIT $1
            ",
            i64::from(n)
        )
        .fetch_all(&self.pool)
        .await?
        .into_iter()
        .map(|r| {
            Ok(Image {
                id: null_error!(r.image_id),
                url: null_error!(r.url),
                image_hoster_id: null_error!(r.hoster_id),
                downvotes: u32::try_from(null_error!(r.downvotes))?,
                upvotes: u32::try_from(null_error!(r.upvotes))?,
                rank: null_error!(r.rank),
                approved: null_error!(r.approved),
                report_count: u32::try_from(null_error!(r.report_count))?,
                upload_date: null_error!(r.link_date),
            })
        })
        .collect::<Result<Vec<_>>>()
    }

    async fn delete_image(&self, id: Uuid) -> Result<()> {
        // Todo on delete cascade?
        sqlx::query!("DELETE FROM image WHERE image_id = $1", id)
            .execute(&self.pool)
            .await?;

        Ok(())
    }

    async fn mark_as_checked(&self, id: Uuid) -> Result<()> {
        sqlx::query!(
            "UPDATE image SET last_verified_date = CURRENT_DATE WHERE image_id = $1",
            id
        )
        .execute(&self.pool)
        .await?;
        Ok(())
    }
}

#[cfg(test)]
mod test {
    #![allow(clippy::unwrap_used)]
    use super::*;
    use chrono::Local;
    use sqlx::PgPool;

    #[sqlx::test(fixtures("meal", "image_review_data", "canteen", "line", "food_plan"))]
    async fn test_get_n_images_by_rank_date(pool: PgPool) {
        let review = PersistentImageReviewData { pool };
        let n = 100;
        let date = Local::now().date_naive();

        let images = review.get_n_images_by_rank_date(n, date).await.unwrap();
        assert_eq!(images, provide_dummy_images()[0]);

        let n = 2;
        let images = review.get_n_images_by_rank_date(n, date).await.unwrap();
        assert!(images.len() <= n.try_into().unwrap());
        assert!(review
            .get_n_images_by_rank_date(0, date)
            .await
            .unwrap()
            .is_empty());
        assert!(review
            .get_n_images_by_rank_date(n, Date::default())
            .await
            .unwrap()
            .is_empty());
    }

    #[sqlx::test(fixtures("meal", "image_review_data", "canteen", "line", "food_plan"))]
    async fn test_get_n_images_next_week_by_rank_not_checked_last_week(pool: PgPool) {
        let review = PersistentImageReviewData { pool };
        let n = 100;

        let images = review
            .get_n_images_next_week_by_rank_not_checked_last_week(n)
            .await
            .unwrap();
        assert_eq!(images, provide_dummy_images()[1]);

        let n = 2;
        let images = review
            .get_n_images_next_week_by_rank_not_checked_last_week(n)
            .await
            .unwrap();
        assert!(images.len() <= n.try_into().unwrap());
        assert!(review
            .get_n_images_next_week_by_rank_not_checked_last_week(0)
            .await
            .unwrap()
            .is_empty());
    }

    #[sqlx::test(fixtures("meal", "image_review_data", "canteen", "line", "food_plan"))]
    async fn test_get_n_images_by_last_checked_not_checked_last_week(pool: PgPool) {
        let review = PersistentImageReviewData { pool };
        let n = 100;

        let images = review
            .get_n_images_by_last_checked_not_checked_last_week(n)
            .await
            .unwrap();
        assert_eq!(images, provide_dummy_images()[2]);

        let n = 2;
        let images = review
            .get_n_images_by_last_checked_not_checked_last_week(n)
            .await
            .unwrap();
        assert!(images.len() <= n.try_into().unwrap());
        assert!(review
            .get_n_images_by_last_checked_not_checked_last_week(0)
            .await
            .unwrap()
            .is_empty());
    }

    fn provide_dummy_images() -> [Vec<Image>; 3] {
        let image1 = Image {
            id: Uuid::parse_str("1aa73d5d-1701-4975-aa3c-1422a8bc10e8").unwrap(),
            image_hoster_id: "test3".to_string(),
            url: "www.test.com".to_string(),
            approved: true,
            rank: 0.5,
            downvotes: 0,
            upvotes: 0,
            upload_date: Local::now().date_naive(),
            report_count: 0,
        };
        let image2 = Image {
            id: Uuid::parse_str("1ec94803-7b63-4fa0-bd8d-f9d2f8edb6ea").unwrap(),
            image_hoster_id: "test1".to_string(),
            url: "www.test.com".to_string(),
            approved: false,
            ..image1
        };
        let image3 = Image {
            id: Uuid::parse_str("68153ab6-ebbf-48f4-b8dd-a9b2a19a5221").unwrap(),
            image_hoster_id: "test5".to_string(),
            url: "www.test.com".to_string(),
            approved: false,
            ..image2
        };
        let image4 = Image {
            id: Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap(),
            image_hoster_id: "test2".to_string(),
            url: "www.test.com".to_string(),
            approved: false,
            ..image3
        };
        let image5 = Image {
            id: Uuid::parse_str("ea8cce48-a3c7-4f8e-a222-5f3891c13804").unwrap(),
            image_hoster_id: "test4".to_string(),
            url: "www.test.com".to_string(),
            approved: false,
            ..image4
        };
        [
            vec![
                image1.clone(),
                image2,
                image3.clone(),
                image4.clone(),
                image5.clone(),
            ],
            vec![
                image1.clone(),
                image3.clone(),
                image4.clone(),
                image5.clone(),
            ],
            vec![image3, image5, image1, image4],
        ]
    }

    #[sqlx::test(fixtures("meal", "image_review_data"))]
    async fn test_delete_image(pool: PgPool) {
        let review = PersistentImageReviewData { pool: pool.clone() };
        let id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();
        let other_id = Uuid::parse_str("1aa73d5d-1701-4975-aa3c-1422a8bc10e8").unwrap();

        assert!(has_value(&pool, id).await);
        assert!(has_value(&pool, other_id).await);
        assert!(review.delete_image(id).await.is_ok());
        assert!(!has_value(&pool, id).await);
        assert!(has_value(&pool, other_id).await);
    }

    async fn has_value(pool: &PgPool, id: Uuid) -> bool {
        sqlx::query!("SELECT * FROM image WHERE image_id = $1", id)
            .fetch_optional(pool)
            .await
            .unwrap()
            .is_some()
    }

    #[sqlx::test(fixtures("meal", "image_review_data"))]
    async fn test_mark_as_checked(pool: PgPool) {
        let review = PersistentImageReviewData { pool: pool.clone() };
        let id = Uuid::parse_str("76b904fe-d0f1-4122-8832-d0e21acab86d").unwrap();

        assert_eq!(images_checked_today(&pool).await, 0);
        assert!(review.mark_as_checked(id).await.is_ok());
        assert_eq!(images_checked_today(&pool).await, 1);
    }

    async fn images_checked_today(pool: &PgPool) -> usize {
        let test = sqlx::query!("SELECT * FROM image WHERE last_verified_date = CURRENT_DATE")
            .fetch_all(pool)
            .await;
        test.unwrap().len()
    }
}
