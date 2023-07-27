-- Add up migration script here

CREATE TYPE report_reason AS ENUM ('OFFENSIVE','ADVERT','NO_MEAL','WRONG_MEAL','VIOLATES_RIGHTS','OTHER');


CREATE TABLE image_report (
  image_id uuid NOT NULL REFERENCES image(image_id) ON DELETE CASCADE,
  user_id uuid NOT NULL,
  report_date date NOT NULL DEFAULT CURRENT_DATE,
  reason report_reason NOT NULL,
  PRIMARY KEY (image_id, user_id)
);