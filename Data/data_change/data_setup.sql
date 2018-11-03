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

update branch set branch_name = 'CHI NHÁNH B?NH TH?Y 1', latidute = '10.0531254', longtidute = '105.741299', address = 'Long Hoà, B?nh Th?y, C?n Thõ, Vi?t Nam' where id = '1'
update branch set branch_name = 'CHI NHÁNH B?NH TH?Y 2', latidute = '10.0587948', longtidute = '105.7538828', address = '393a, Tr?n Quang Di?u, An Th?i, B?nh Th?y, C?n Thõ, Vi?t Nam' where id = '2'
update branch set branch_name = 'CHI NHÁNH NINH KI?U 1', latidute = '10.0227358', longtidute = '105.7652209', address = 'Ba Tháng Hai, Hýng L?i, Ninh Ki?u, C?n Thõ, Vi?t Nam' where id = '3'
update branch set branch_name = 'CHI NHÁNH NINH KI?U 2', latidute = '10.0235621', longtidute = '105.7667095', address = '178 Ba Tháng Hai, Hýng L?i, Ninh Ki?u, C?n Thõ, Vi?t Nam' where id = '4'