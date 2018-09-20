create table dry (
    id numeric(19,0) primary key,
    dry_bag_id numeric(19,0),
    drying_machine_id numeric(19,0),
    create_by	numeric(19,0),
    update_by	numeric(19,0),
    create_date	timestamp,
    update_date	timestamp,
    status varchar(200)
);

create sequence dry_seq;

alter table dry add constraint fk_dry_dry_bag_id foreign key (dry_bag_id) references wash_bag(id);
alter table dry add constraint fk_dry_dry_drying_machine_id foreign key (drying_machine_id) references dryer(id);
