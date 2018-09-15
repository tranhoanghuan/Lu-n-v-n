create table material(
    id numeric(19,0) primary key,
    material_name varchar(2000),
    CREATE_BY	NUMERIC(19,0),
    UPDATE_BY	NUMERIC(19,0),
    CREATE_DATE	TIMESTAMP,
    UPDATE_DATE	TIMESTAMP,
    status varchar(200)
);

create sequence material_seq;