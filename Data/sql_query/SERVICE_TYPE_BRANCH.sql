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

alter table service_type_branch add constraint fk_service_type_branch_branch_id foreign key (branch_id) references branch(id);

alter table service_type_branch add constraint fk_service_type_branch_service_type_id foreign key (service_type_id) references service_type(id);
