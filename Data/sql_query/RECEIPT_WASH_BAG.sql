create table receipt_wash_bag(
    id numeric(19,0) primary key,
    wash_bag_id numeric(19,0),
    receipt_id numeric(19,0),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);