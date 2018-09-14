create table receipt_detail(
    id numeric(19,0) primary key,
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence receipt_detail_seq;