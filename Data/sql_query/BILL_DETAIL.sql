create table BILL_DETAIL(
    id numeric(19,0) primary key,
    bill_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    note varchar(4000),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence bill_detail_seq;