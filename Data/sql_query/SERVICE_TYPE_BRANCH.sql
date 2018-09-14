create table service_type_branch(
    id numeric(19,0),
    service_type_id numeric(19,0),
    branch_id numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence service_type_branch_seq;