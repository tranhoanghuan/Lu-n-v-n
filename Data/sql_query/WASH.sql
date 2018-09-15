create table wash (
    id numeric(19,0) primary key,
    wash_bag_id numeric(19,0),
    washing_machine_id numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence wash_seq;

alter table wash add constraint fk_wash_wash_bag_id foreign key (wash_bag_id) references wash_bag(id);
alter table wash add constraint fk_wash_wash_washing_machine_id foreign key (washing_machine_id) references washing_machine(id);
/
