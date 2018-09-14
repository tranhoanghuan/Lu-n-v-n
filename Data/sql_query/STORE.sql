create table store (
    id numeric(19,0) primary key,
    store_name varchar(2000),
    address varchar(4000),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
)
create sequence store_seq;