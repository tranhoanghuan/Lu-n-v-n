create table staff (
    id numeric(19,0) primary key,
    staff_type_name varchar(2000),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp
);

create sequence staff_type_seq;


