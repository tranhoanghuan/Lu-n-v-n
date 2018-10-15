--Add unit_price in to service_type
alter table service_type add column unit_price_id numeric(19,0);
alter table service_type add CONSTRAINT fk_service_type_unit_price_id foreign key (unit_price_id) REFERENCES unit_price(id);


--change hash_code to hash_codes;
alter table customer drop hash_code;
alter table staff drop hash_code;
alter table customer add column hash_codes varchar(200);
alter table staff add column hash_codes varchar(200);

--Add table for image
create table public.post (
  id serial primary key,
  headline text,
  body text,
  header_image_file text
);
--add image for customer,staff, product,promotion,service,branch,store;

alter table customer add column customer_avatar INTEGER REFERENCES post(id);
alter table staff add column staff_avatar INTEGER REFERENCES post(id);
alter table product add column product_avatar INTEGER REFERENCES post(id);
alter table service_type add column service_type_avatar INTEGER REFERENCES post(id);
alter table branch add column branch_avatar INTEGER REFERENCES post(id);
alter table store add column store_avatar INTEGER REFERENCES post(id);

--for statistics 

create table statistics (

    id serial primary key,
    table_name varchar(4000),
    code varchar(4000),
    st_value varchar(4000),
    st_ext_value varchar(4000),
    CREATE_DATE	TIMESTAMP default now(),
    UPDATE_DATE	TIMESTAMP
);

-- code
--SERVICE_COUNT
--CLOTH COUNT
--PROMOTION_USE_COUNT
--PROMOTION_VALUES
--SCHEDULE_COUNT
--+st_value store time_schedule_no
--+st_value count used times
--PRODUCT_USE_COUNT
--+st_value store id product
--+st_ext_value count used times
--+DRAFT_ORDER
--+SUCCESS_ORDER
--+




