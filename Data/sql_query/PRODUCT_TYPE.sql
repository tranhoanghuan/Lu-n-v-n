create table product_type(
    id NUMERIC(19,0) primary key,
    product_type_name varchar(2000),
    display_order integer,
    status varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP
);

create sequence product_type_seq;
/