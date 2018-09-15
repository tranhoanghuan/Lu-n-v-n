create table wash_bag(
    id numeric(19,0) primary key,
    wash_bag_no varchar(200),
    wash_bag_name varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);
create sequence wash_bag_seq;
/