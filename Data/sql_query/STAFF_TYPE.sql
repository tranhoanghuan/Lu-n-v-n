create table staff_type(
    id numeric(19,0),
    staff_type_name varchar(2000),
    staff_type_no varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence staff_type_seq;