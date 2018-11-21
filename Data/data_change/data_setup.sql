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

update branch set branch_name = 'CHI NHÁNH BÌNH THỦY 1', latidute = '10.0531254', longtidute = '105.741299', address = 'Long Hoà, Bình Thủy, Cần Thơ, Việt Nam' where id = '1'
update branch set branch_name = 'CHI NHÁNH BÌNH THỦY 2', latidute = '10.0587948', longtidute = '105.7538828', address = '393a, Trần Quang Diệu, An Thới, Bình Thủy, Cần Thơ, Việt Nam' where id = '2'
update branch set branch_name = 'CHI NHÁNH NINH KIỀU 1', latidute = '10.0227358', longtidute = '105.7652209', address = 'Ba Tháng Hai, Hưng Lợi, Ninh Kiều, Cần Thơ, Việt Nam' where id = '3'
update branch set branch_name = 'CHI NHÁNH NINH KIỀU 2', latidute = '10.0235621', longtidute = '105.7667095', address = '178 Ba Tháng Hai, Hưng Lợi, Ninh Kiều, Cần Thơ, Việt Nam' where id = '4'


--promotion
INSERT INTO public.promotion(
	promotion_name, sale, date_start, date_end, promotion_code, create_date, status)
	VALUES ('Khuyến mãi đợt 1', 20, '2018/11/06', '2018/11/10', 'D1_112018', current_date, 'ACTIVE');

INSERT INTO public.promotion(
	promotion_name, sale, date_start, date_end, promotion_code, create_date, status)
	VALUES ('Khuyến mãi đợt 2', 10, '2018/11/11', '2018/11/15', 'D2_112018', current_date, 'ACTIVE');

INSERT INTO public.promotion(
	promotion_name, sale, date_start, date_end, promotion_code, create_date, status)
	VALUES ('Khuyến mãi đợt 3', 10, '2018/11/16', '2018/11/19', 'D3_112018', current_date, 'ACTIVE');


insert into promotion_branch(promotion_id, branch_id, status)
select pr.id, br.id, 'ACTIVE' from promotion pr, branch br where br.id=1 limit 4;

insert into promotion_branch(promotion_id, branch_id, status)
select pr.id, br.id, 'ACTIVE' from promotion pr, branch br where br.id=2 limit 4;

insert into promotion_branch(promotion_id, branch_id, status)
select pr.id, br.id, 'ACTIVE' from promotion pr, branch br where br.id=3 limit 4;

insert into promotion_branch(promotion_id, branch_id, status)
select pr.id, br.id, 'ACTIVE' from promotion pr, branch br where br.id=4 limit 4;

--unit_price

INSERT INTO public.unit_price(
	service_type_id, unit_id, apply_date, price, create_date, status)
	select s.id, '4', current_timestamp, '10000', current_timestamp, 'ACTIVE' from service_type s;

INSERT INTO public.unit_price(
	product_id, service_type_id, material_id, unit_id, apply_date, price, create_date, status)
	select p.id, s.id, m.id, '1', current_timestamp, '1000', current_timestamp, 'ACTIVE' from product p, service_type s, material m 
	


