create table product(
    id numeric(19,0) primary key,
    product_name varchar(2000),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200),
    product_image text,
    short_desc varchar(200),
);

create sequence product_seq;