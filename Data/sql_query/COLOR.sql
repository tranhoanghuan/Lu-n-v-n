create table color (
    id numeric(19,0) primary key,
    color_name varchar(2000),
    color_group_id numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence color_seq;