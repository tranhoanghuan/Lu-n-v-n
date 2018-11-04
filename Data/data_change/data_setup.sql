--store
INSERT INTO public.store(
	store_name, address, create_by, update_by, status, store_avatar)
	VALUES ('CAN_THO_STORE', 'Xuan Khanh, Ninh Kieu, Can Tho', 0, 0, 'ACTIVE', 3);
--branch
INSERT INTO public.branch(
	branch_name, store_id, address, create_by, update_by, status, branch_avatar)
	VALUES ('CHI NHANH BINH THUY', 1, 'Ninh Kieu, Can Tho', 0, 0,'ACTIVE',17);

INSERT INTO public.branch(
	branch_name, store_id, address, create_by, update_by, status, branch_avatar)
	VALUES ('CHI NHANH NINH KIEU', 1, 'Ninh Kieu, Can Tho', 0, 0,'ACTIVE',17);

insert into service_type_branch(service_type_id, branch_id, status)
select st.id, br.id, 'ACTIVE' from service_type st, branch br where br.id=2 limit 8;

update branch set branch_name = 'CHI NHÁNH BÌNH THỦY 1', latidute = '10.0531254', longtidute = '105.741299', address = 'Long Hoà, Bình Thủy, Cần Thơ, Việt Nam' where id = '1';
update branch set branch_name = 'CHI NHÁNH BÌNH THỦY 2', latidute = '10.0587948', longtidute = '105.7538828', address = '393a, Trần Quang Diệu, An Thới, Bình Thủy, Cần Thơ, Việt Nam' where id = '2';
update branch set branch_name = 'CHI NHÁNH NINH KIỀU 1', latidute = '10.0227358', longtidute = '105.7652209', address = 'Ba Tháng Hai, Hưng Lợi, Ninh Kiều, Cần Thơ, Việt Nam' where id = '3';
update branch set branch_name = 'CHI NHÁNH NINH KIỀU 2', latidute = '10.0235621', longtidute = '105.7667095', address = '178 Ba Tháng Hai, Hưng Lợi, Ninh Kiều, Cần Thơ, Việt Nam' where id = '4';
--Washing machine
insert into washing_machine(branch_id, bought_date, capacity, status, washer_code)
select 2, now(), 10, 'ACTIVE', 'WASHER_'||nextVal('washing_machine_seq') from branch
