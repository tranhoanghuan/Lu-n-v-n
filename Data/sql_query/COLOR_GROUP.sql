create table color_group(
    id numeric(19,0) primary key,
    color_group_name varchar(2000),
    color_group_no varchar(200),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence color_group_seq;