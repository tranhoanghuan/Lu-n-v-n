create table dryer (
    id numeric (19,0) primary key,
    branch_id numeric(19,0),
    dryer_no varchar(200),
    bought_date date,
    buyer numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence dryer_seq;

alter table dryer add constraint fk_dryer_branch_id foreign key (branch_id) references branch(id);

