create table unit(
    id numeric(19,0) primary key,
    unit_name varchar(200),
    status varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP
);

create sequence unit_seq;
