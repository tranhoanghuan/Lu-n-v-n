create table washing_machine (
    id numeric (19,0) primary key,
    branch_id numeric(19,0),
    washing_machine_no varchar(200),
    bought_date date,
    buyer numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence washing_machine_seq;
alter table washing_machine add constraint fk_washing_machine_branch_id foreign key (branch_id) references branch(id);
