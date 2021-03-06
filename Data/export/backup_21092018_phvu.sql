PGDMP     $    ;                v            laundry_schema    10.4    10.4 �    �           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            �           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            �           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false            �           1262    18821    laundry_schema    DATABASE     �   CREATE DATABASE laundry_schema WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'English_United States.1252' LC_CTYPE = 'English_United States.1252';
    DROP DATABASE laundry_schema;
             luandry    false                        2615    2200    public    SCHEMA        CREATE SCHEMA public;
    DROP SCHEMA public;
             postgres    false            �           0    0    SCHEMA public    COMMENT     6   COMMENT ON SCHEMA public IS 'standard public schema';
                  postgres    false    3                        3079    12924    plpgsql 	   EXTENSION     ?   CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;
    DROP EXTENSION plpgsql;
                  false            �           0    0    EXTENSION plpgsql    COMMENT     @   COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';
                       false    1                       1247    19676 	   jwt_token    TYPE     �   CREATE TYPE public.jwt_token AS (
	role text,
	exp integer,
	person_id integer,
	is_admin boolean,
	username character varying
);
    DROP TYPE public.jwt_token;
       public       postgres    false    3                       1255    19679    authenticate(text, text)    FUNCTION     9  CREATE FUNCTION public.authenticate(email text, password text) RETURNS public.jwt_token
    LANGUAGE plpgsql STRICT SECURITY DEFINER
    AS $$
declare
  customer customer;
begin
  select a.* into customer
    from customer as a
    where a.email = authenticate.email;

  if account.hash_code = crypt(password, customer.hash_code) then
    return (
      'person_role',
      extract(epoch from now() + interval '7 days'),
      customer.id,
      customer.customer_no,
      customer.username
    )::laundry_schema.jwt_token;
  else
    return null;
  end if;
end;
$$;
 >   DROP FUNCTION public.authenticate(email text, password text);
       public       postgres    false    3    1    795            �            1259    19515    bill    TABLE     �  CREATE TABLE public.bill (
    id numeric(19,0) NOT NULL,
    bill_no character varying(200),
    customer_id numeric(19,0),
    receipt_id numeric(19,0),
    payment_id numeric(19,0),
    order_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.bill;
       public         postgres    false    3                       1259    19546    bill_detail    TABLE       CREATE TABLE public.bill_detail (
    id numeric(19,0) NOT NULL,
    bill_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    note character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.bill_detail;
       public         postgres    false    3            �            1259    19290    bill_detail_seq    SEQUENCE     x   CREATE SEQUENCE public.bill_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.bill_detail_seq;
       public       postgres    false    3            �            1259    19141    bill_seq    SEQUENCE     q   CREATE SEQUENCE public.bill_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.bill_seq;
       public       postgres    false    3            �            1259    18861 
   branch_seq    SEQUENCE     s   CREATE SEQUENCE public.branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 !   DROP SEQUENCE public.branch_seq;
       public       postgres    false    3            �            1259    18853    branch    TABLE     �  CREATE TABLE public.branch (
    id numeric(19,0) DEFAULT nextval('public.branch_seq'::regclass) NOT NULL,
    branch_name character varying(2000) NOT NULL,
    store_id numeric(19,0) NOT NULL,
    address character varying(4000),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone NOT NULL,
    update_date timestamp without time zone,
    status character varying(200),
    branch_no character varying(200)
);
    DROP TABLE public.branch;
       public         postgres    false    201    3            �            1259    18936 	   color_seq    SEQUENCE     r   CREATE SEQUENCE public.color_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.color_seq;
       public       postgres    false    3            �            1259    18928    color    TABLE     �  CREATE TABLE public.color (
    id numeric(19,0) DEFAULT nextval('public.color_seq'::regclass) NOT NULL,
    color_name character varying(2000),
    color_group_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200),
    color_no character varying(200)
);
    DROP TABLE public.color;
       public         postgres    false    213    3            �            1259    18925    color_group_seq    SEQUENCE     x   CREATE SEQUENCE public.color_group_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.color_group_seq;
       public       postgres    false    3            �            1259    18917    color_group    TABLE     �  CREATE TABLE public.color_group (
    id numeric(19,0) DEFAULT nextval('public.color_group_seq'::regclass) NOT NULL,
    color_group_name character varying(2000),
    color_group_no character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.color_group;
       public         postgres    false    211    3            �            1259    19041    customer_seq    SEQUENCE     u   CREATE SEQUENCE public.customer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.customer_seq;
       public       postgres    false    3            �            1259    19033    customer    TABLE     �  CREATE TABLE public.customer (
    id numeric(19,0) DEFAULT nextval('public.customer_seq'::regclass) NOT NULL,
    full_name character varying(2000),
    email character varying(4000),
    username character varying(4000),
    customer_no character varying(4000),
    password character varying(4000),
    gender boolean,
    address character varying(4000),
    phone character varying(4000),
    status boolean,
    hash_code character varying(4000),
    lock_status boolean,
    lock_time integer,
    timelock timestamp without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone
);
    DROP TABLE public.customer;
       public         postgres    false    231    3            �            1259    19180    customer_order_seq    SEQUENCE     {   CREATE SEQUENCE public.customer_order_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.customer_order_seq;
       public       postgres    false    3            �            1259    19175    customer_order    TABLE     �  CREATE TABLE public.customer_order (
    id numeric(19,0) DEFAULT nextval('public.customer_order_seq'::regclass) NOT NULL,
    order_no character varying(200),
    customer_id numeric(19,0),
    branch_id numeric(19,0),
    receiver_id numeric(19,0),
    shipper_id numeric(19,0),
    payment_id numeric(19,0),
    pick_up_date date,
    pick_up_time_id numeric(19,0),
    delivery_date date,
    delivery_time_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200),
    pick_up_place character varying(4000),
    delivery_place character varying(4000)
);
 "   DROP TABLE public.customer_order;
       public         postgres    false    247    3            �            1259    19112    dry_seq    SEQUENCE     p   CREATE SEQUENCE public.dry_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.dry_seq;
       public       postgres    false    3            �            1259    19107    dry    TABLE     a  CREATE TABLE public.dry (
    id numeric(19,0) DEFAULT nextval('public.dry_seq'::regclass) NOT NULL,
    dry_bag_id numeric(19,0),
    drying_machine_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.dry;
       public         postgres    false    241    3            �            1259    19026 	   dryer_seq    SEQUENCE     r   CREATE SEQUENCE public.dryer_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.dryer_seq;
       public       postgres    false    3            �            1259    19023    dryer    TABLE     �  CREATE TABLE public.dryer (
    id numeric(19,0) DEFAULT nextval('public.dryer_seq'::regclass) NOT NULL,
    branch_id numeric(19,0),
    dryer_no character varying(200),
    bought_date date,
    buyer numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.dryer;
       public         postgres    false    229    3            �            1259    18905 	   label_seq    SEQUENCE     r   CREATE SEQUENCE public.label_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.label_seq;
       public       postgres    false    3            �            1259    18897    label    TABLE     J  CREATE TABLE public.label (
    id numeric(19,0) DEFAULT nextval('public.label_seq'::regclass) NOT NULL,
    label_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.label;
       public         postgres    false    207    3            �            1259    18915    material_seq    SEQUENCE     u   CREATE SEQUENCE public.material_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.material_seq;
       public       postgres    false    3            �            1259    18907    material    TABLE     S  CREATE TABLE public.material (
    id numeric(19,0) DEFAULT nextval('public.material_seq'::regclass) NOT NULL,
    material_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.material;
       public         postgres    false    209    3            �            1259    19240    order_detail_seq    SEQUENCE     y   CREATE SEQUENCE public.order_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.order_detail_seq;
       public       postgres    false    3            �            1259    19232    order_detail    TABLE     V  CREATE TABLE public.order_detail (
    id numeric(19,0) DEFAULT nextval('public.order_detail_seq'::regclass) NOT NULL,
    order_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    note character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
     DROP TABLE public.order_detail;
       public         postgres    false    249    3            �            1259    19134    payment_seq    SEQUENCE     t   CREATE SEQUENCE public.payment_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.payment_seq;
       public       postgres    false    3            �            1259    19126    payment    TABLE     P  CREATE TABLE public.payment (
    id numeric(19,0) DEFAULT nextval('public.payment_seq'::regclass) NOT NULL,
    payment_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.payment;
       public         postgres    false    243    3            �            1259    18961    product_seq    SEQUENCE     t   CREATE SEQUENCE public.product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.product_seq;
       public       postgres    false    3            �            1259    18953    product    TABLE     �  CREATE TABLE public.product (
    id numeric(19,0) DEFAULT nextval('public.product_seq'::regclass) NOT NULL,
    product_name character varying(2000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200),
    product_image text,
    short_desc character varying(200),
    producy_type_id numeric(19,0)
);
    DROP TABLE public.product;
       public         postgres    false    217    3            �            1259    18951    product_type_seq    SEQUENCE     y   CREATE SEQUENCE public.product_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.product_type_seq;
       public       postgres    false    3            �            1259    18943    product_type    TABLE     z  CREATE TABLE public.product_type (
    id numeric(19,0) DEFAULT nextval('public.product_type_seq'::regclass) NOT NULL,
    product_type_name character varying(2000),
    display_order integer,
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone
);
     DROP TABLE public.product_type;
       public         postgres    false    215    3            �            1259    18976    promotion_seq    SEQUENCE     v   CREATE SEQUENCE public.promotion_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 $   DROP SEQUENCE public.promotion_seq;
       public       postgres    false    3            �            1259    18968 	   promotion    TABLE     �  CREATE TABLE public.promotion (
    id numeric(19,0) DEFAULT nextval('public.promotion_seq'::regclass) NOT NULL,
    promotion_name character varying(2000),
    sale numeric(2,0),
    date_start date,
    date_end date,
    promotion_code character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.promotion;
       public         postgres    false    219    3            �            1259    19046    promotion_branch_seq    SEQUENCE     }   CREATE SEQUENCE public.promotion_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.promotion_branch_seq;
       public       postgres    false    3            �            1259    19043    promotion_branch    TABLE     u  CREATE TABLE public.promotion_branch (
    id numeric(19,0) DEFAULT nextval('public.promotion_branch_seq'::regclass) NOT NULL,
    promotion_id numeric(19,0),
    branch_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 $   DROP TABLE public.promotion_branch;
       public         postgres    false    233    3                        1259    19520    receipt    TABLE     �  CREATE TABLE public.receipt (
    id numeric(19,0) NOT NULL,
    customer_id numeric(19,0),
    order_id numeric(19,0),
    receipt_no character varying(200),
    receiver_id numeric(19,0),
    shipper_id numeric(19,0),
    pick_up_time timestamp without time zone,
    delivery_time timestamp without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.receipt;
       public         postgres    false    3                       1259    19629    receipt_detail    TABLE       CREATE TABLE public.receipt_detail (
    id numeric(19,0) NOT NULL,
    receipt_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 "   DROP TABLE public.receipt_detail;
       public         postgres    false    3            �            1259    19354    receipt_detail_seq    SEQUENCE     {   CREATE SEQUENCE public.receipt_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 )   DROP SEQUENCE public.receipt_detail_seq;
       public       postgres    false    3            �            1259    19168    receipt_seq    SEQUENCE     t   CREATE SEQUENCE public.receipt_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 "   DROP SEQUENCE public.receipt_seq;
       public       postgres    false    3                       1259    19614    receipt_wash_bag    TABLE     <  CREATE TABLE public.receipt_wash_bag (
    id numeric(19,0) NOT NULL,
    wash_bag_id numeric(19,0),
    receipt_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 $   DROP TABLE public.receipt_wash_bag;
       public         postgres    false    3            �            1259    19337    receipt_wash_bag_seq    SEQUENCE     }   CREATE SEQUENCE public.receipt_wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 +   DROP SEQUENCE public.receipt_wash_bag_seq;
       public       postgres    false    3            �            1259    19001    service_type_seq    SEQUENCE     y   CREATE SEQUENCE public.service_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public.service_type_seq;
       public       postgres    false    3            �            1259    18993    service_type    TABLE     �  CREATE TABLE public.service_type (
    id numeric(19,0) DEFAULT nextval('public.service_type_seq'::regclass) NOT NULL,
    service_type_name character varying(2000),
    service_type_desc character varying(4000),
    promotion_id numeric(19,0),
    status character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    unit_price_id numeric(19,0)
);
     DROP TABLE public.service_type;
       public         postgres    false    225    3            �            1259    19011    service_type_branch_seq    SEQUENCE     �   CREATE SEQUENCE public.service_type_branch_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 .   DROP SEQUENCE public.service_type_branch_seq;
       public       postgres    false    3            �            1259    19008    service_type_branch    TABLE     u  CREATE TABLE public.service_type_branch (
    id numeric(19,0) DEFAULT nextval('public.service_type_branch_seq'::regclass),
    service_type_id numeric(19,0),
    branch_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 '   DROP TABLE public.service_type_branch;
       public         postgres    false    227    3            �            1259    18883 	   staff_seq    SEQUENCE     r   CREATE SEQUENCE public.staff_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.staff_seq;
       public       postgres    false    3            �            1259    18875    staff    TABLE     �  CREATE TABLE public.staff (
    id numeric(19,0) DEFAULT nextval('public.staff_seq'::regclass) NOT NULL,
    full_name character varying(2000),
    email character varying(4000),
    username character varying(4000),
    staff_no character varying(4000),
    password character varying(4000),
    gender boolean,
    address character varying(4000),
    phone character varying(4000),
    status boolean,
    hash_code character varying(4000),
    lock_status boolean,
    lock_time integer,
    timelock timestamp without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    staff_type_id numeric(19,0),
    branch_id numeric(19,0)
);
    DROP TABLE public.staff;
       public         postgres    false    205    3            �            1259    18828    staff_type_seq    SEQUENCE     w   CREATE SEQUENCE public.staff_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.staff_type_seq;
       public       postgres    false    3            �            1259    18822 
   staff_type    TABLE     �  CREATE TABLE public.staff_type (
    id numeric(19,0) DEFAULT nextval('public.staff_type_seq'::regclass) NOT NULL,
    staff_type_name character varying(2000),
    staff_type_no character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.staff_type;
       public         postgres    false    197    3            �            1259    18838 	   store_seq    SEQUENCE     r   CREATE SEQUENCE public.store_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
     DROP SEQUENCE public.store_seq;
       public       postgres    false    3            �            1259    18830    store    TABLE     o  CREATE TABLE public.store (
    id numeric(19,0) DEFAULT nextval('public.store_seq'::regclass) NOT NULL,
    store_name character varying(2000),
    address character varying(4000),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.store;
       public         postgres    false    199    3            �            1259    19064    time_schedule_seq    SEQUENCE     z   CREATE SEQUENCE public.time_schedule_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 (   DROP SEQUENCE public.time_schedule_seq;
       public       postgres    false    3            �            1259    19059    time_schedule    TABLE     �  CREATE TABLE public.time_schedule (
    id numeric(19,0) DEFAULT nextval('public.time_schedule_seq'::regclass) NOT NULL,
    time_schedule_no character varying(200),
    time_start time without time zone,
    time_end time without time zone,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 !   DROP TABLE public.time_schedule;
       public         postgres    false    235    3            �            1259    18873    unit_seq    SEQUENCE     q   CREATE SEQUENCE public.unit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.unit_seq;
       public       postgres    false    3            �            1259    18868    unit    TABLE     a  CREATE TABLE public.unit (
    id numeric(19,0) DEFAULT nextval('public.unit_seq'::regclass) NOT NULL,
    unit_name character varying(200) NOT NULL,
    status character varying(200),
    create_by numeric(19,0) NOT NULL,
    update_by numeric(19,0),
    create_date timestamp without time zone NOT NULL,
    update_date timestamp without time zone
);
    DROP TABLE public.unit;
       public         postgres    false    203    3            �            1259    19071    unit_price_seq    SEQUENCE     w   CREATE SEQUENCE public.unit_price_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 %   DROP SEQUENCE public.unit_price_seq;
       public       postgres    false    3            �            1259    19066 
   unit_price    TABLE     �  CREATE TABLE public.unit_price (
    id numeric(19,0) DEFAULT nextval('public.unit_price_seq'::regclass) NOT NULL,
    product_id numeric(19,0),
    service_type_id numeric(19,0),
    material_id numeric(19,0),
    unit_id numeric(19,0),
    apply_date timestamp without time zone,
    price money,
    max_price money,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.unit_price;
       public         postgres    false    237    3            �            1259    19093    wash_seq    SEQUENCE     q   CREATE SEQUENCE public.wash_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
    DROP SEQUENCE public.wash_seq;
       public       postgres    false    3            �            1259    19088    wash    TABLE     e  CREATE TABLE public.wash (
    id numeric(19,0) DEFAULT nextval('public.wash_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    washing_machine_id numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.wash;
       public         postgres    false    239    3            �            1259    18986    wash_bag_seq    SEQUENCE     u   CREATE SEQUENCE public.wash_bag_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 #   DROP SEQUENCE public.wash_bag_seq;
       public       postgres    false    3            �            1259    18978    wash_bag    TABLE     P  CREATE TABLE public.wash_bag (
    id numeric(19,0) DEFAULT nextval('public.wash_bag_seq'::regclass) NOT NULL,
    wash_bag_no character varying(200),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
    DROP TABLE public.wash_bag;
       public         postgres    false    221    3            �            1259    19407    wash_bag_detail_seq    SEQUENCE     |   CREATE SEQUENCE public.wash_bag_detail_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.wash_bag_detail_seq;
       public       postgres    false    3            �            1259    19402    wash_bag_detail    TABLE     =  CREATE TABLE public.wash_bag_detail (
    id numeric(19,0) DEFAULT nextval('public.wash_bag_detail_seq'::regclass) NOT NULL,
    wash_bag_id numeric(19,0),
    service_type_id numeric(19,0),
    unit_id numeric(19,0),
    label_id numeric(19,0),
    color_id numeric(19,0),
    product_id numeric(19,0),
    material_id numeric(19,0),
    unit_price_id numeric(19,0),
    amount integer,
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 #   DROP TABLE public.wash_bag_detail;
       public         postgres    false    254    3            �            1259    18991    washing_machine_seq    SEQUENCE     |   CREATE SEQUENCE public.washing_machine_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 *   DROP SEQUENCE public.washing_machine_seq;
       public       postgres    false    3            �            1259    18988    washing_machine    TABLE     �  CREATE TABLE public.washing_machine (
    id numeric(19,0) DEFAULT nextval('public.washing_machine_seq'::regclass) NOT NULL,
    branch_id numeric(19,0),
    washing_machine_no character varying(200),
    bought_date date,
    buyer numeric(19,0),
    create_by numeric(19,0),
    update_by numeric(19,0),
    create_date timestamp without time zone,
    update_date timestamp without time zone,
    status character varying(200)
);
 #   DROP TABLE public.washing_machine;
       public         postgres    false    223    3            �          0    19515    bill 
   TABLE DATA               �   COPY public.bill (id, bill_no, customer_id, receipt_id, payment_id, order_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    255   �E      �          0    19546    bill_detail 
   TABLE DATA               �   COPY public.bill_detail (id, bill_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, unit_price_id, amount, note, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    257   �E      U          0    18853    branch 
   TABLE DATA               �   COPY public.branch (id, branch_name, store_id, address, create_by, update_by, create_date, update_date, status, branch_no) FROM stdin;
    public       postgres    false    200   �E      a          0    18928    color 
   TABLE DATA               �   COPY public.color (id, color_name, color_group_id, create_by, update_by, create_date, update_date, status, color_no) FROM stdin;
    public       postgres    false    212   F      _          0    18917    color_group 
   TABLE DATA               �   COPY public.color_group (id, color_group_name, color_group_no, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    210   #F      s          0    19033    customer 
   TABLE DATA               �   COPY public.customer (id, full_name, email, username, customer_no, password, gender, address, phone, status, hash_code, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    230   @F      �          0    19175    customer_order 
   TABLE DATA               
  COPY public.customer_order (id, order_no, customer_id, branch_id, receiver_id, shipper_id, payment_id, pick_up_date, pick_up_time_id, delivery_date, delivery_time_id, create_by, update_by, create_date, update_date, status, pick_up_place, delivery_place) FROM stdin;
    public       postgres    false    246   �F      }          0    19107    dry 
   TABLE DATA               x   COPY public.dry (id, dry_bag_id, drying_machine_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    240   1G      q          0    19023    dryer 
   TABLE DATA               �   COPY public.dryer (id, branch_id, dryer_no, bought_date, buyer, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    228   NG      [          0    18897    label 
   TABLE DATA               g   COPY public.label (id, label_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    206   kG      ]          0    18907    material 
   TABLE DATA               m   COPY public.material (id, material_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    208   �G      �          0    19232    order_detail 
   TABLE DATA               �   COPY public.order_detail (id, order_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, unit_price_id, amount, note, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    248   �G                0    19126    payment 
   TABLE DATA               k   COPY public.payment (id, payment_name, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    242   �G      e          0    18953    product 
   TABLE DATA               �   COPY public.product (id, product_name, create_by, update_by, create_date, update_date, status, product_image, short_desc, producy_type_id) FROM stdin;
    public       postgres    false    216   �G      c          0    18943    product_type 
   TABLE DATA               �   COPY public.product_type (id, product_type_name, display_order, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    214   �G      g          0    18968 	   promotion 
   TABLE DATA               �   COPY public.promotion (id, promotion_name, sale, date_start, date_end, promotion_code, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    218   H      u          0    19043    promotion_branch 
   TABLE DATA                  COPY public.promotion_branch (id, promotion_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    232   6H      �          0    19520    receipt 
   TABLE DATA               �   COPY public.receipt (id, customer_id, order_id, receipt_no, receiver_id, shipper_id, pick_up_time, delivery_time, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    256   SH      �          0    19629    receipt_detail 
   TABLE DATA               �   COPY public.receipt_detail (id, receipt_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, unit_price_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    259   pH      �          0    19614    receipt_wash_bag 
   TABLE DATA                  COPY public.receipt_wash_bag (id, wash_bag_id, receipt_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    258   �H      m          0    18993    service_type 
   TABLE DATA               �   COPY public.service_type (id, service_type_name, service_type_desc, promotion_id, status, create_by, update_by, create_date, update_date, unit_price_id) FROM stdin;
    public       postgres    false    224   �H      o          0    19008    service_type_branch 
   TABLE DATA               �   COPY public.service_type_branch (id, service_type_id, branch_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    226   �H      Y          0    18875    staff 
   TABLE DATA               �   COPY public.staff (id, full_name, email, username, staff_no, password, gender, address, phone, status, hash_code, lock_status, lock_time, timelock, create_by, update_by, create_date, update_date, staff_type_id, branch_id) FROM stdin;
    public       postgres    false    204   �H      Q          0    18822 
   staff_type 
   TABLE DATA               �   COPY public.staff_type (id, staff_type_name, staff_type_no, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    196   I      S          0    18830    store 
   TABLE DATA               p   COPY public.store (id, store_name, address, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    198   I      w          0    19059    time_schedule 
   TABLE DATA               �   COPY public.time_schedule (id, time_schedule_no, time_start, time_end, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    234   ;I      W          0    18868    unit 
   TABLE DATA               e   COPY public.unit (id, unit_name, status, create_by, update_by, create_date, update_date) FROM stdin;
    public       postgres    false    202   XI      y          0    19066 
   unit_price 
   TABLE DATA               �   COPY public.unit_price (id, product_id, service_type_id, material_id, unit_id, apply_date, price, max_price, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    236   uI      {          0    19088    wash 
   TABLE DATA               {   COPY public.wash (id, wash_bag_id, washing_machine_id, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    238   �I      i          0    18978    wash_bag 
   TABLE DATA               k   COPY public.wash_bag (id, wash_bag_no, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    220   �I      �          0    19402    wash_bag_detail 
   TABLE DATA               �   COPY public.wash_bag_detail (id, wash_bag_id, service_type_id, unit_id, label_id, color_id, product_id, material_id, unit_price_id, amount, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    253   �I      k          0    18988    washing_machine 
   TABLE DATA               �   COPY public.washing_machine (id, branch_id, washing_machine_no, bought_date, buyer, create_by, update_by, create_date, update_date, status) FROM stdin;
    public       postgres    false    222   �I      �           0    0    bill_detail_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.bill_detail_seq', 1, false);
            public       postgres    false    250            �           0    0    bill_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.bill_seq', 1, false);
            public       postgres    false    244            �           0    0 
   branch_seq    SEQUENCE SET     9   SELECT pg_catalog.setval('public.branch_seq', 1, false);
            public       postgres    false    201            �           0    0    color_group_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.color_group_seq', 1, false);
            public       postgres    false    211            �           0    0 	   color_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.color_seq', 1, false);
            public       postgres    false    213            �           0    0    customer_order_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.customer_order_seq', 9, true);
            public       postgres    false    247            �           0    0    customer_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.customer_seq', 19, true);
            public       postgres    false    231            �           0    0    dry_seq    SEQUENCE SET     6   SELECT pg_catalog.setval('public.dry_seq', 1, false);
            public       postgres    false    241            �           0    0 	   dryer_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.dryer_seq', 1, false);
            public       postgres    false    229            �           0    0 	   label_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.label_seq', 1, false);
            public       postgres    false    207            �           0    0    material_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.material_seq', 1, false);
            public       postgres    false    209            �           0    0    order_detail_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.order_detail_seq', 1, false);
            public       postgres    false    249            �           0    0    payment_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.payment_seq', 1, false);
            public       postgres    false    243            �           0    0    product_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.product_seq', 1, false);
            public       postgres    false    217            �           0    0    product_type_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.product_type_seq', 1, false);
            public       postgres    false    215            �           0    0    promotion_branch_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.promotion_branch_seq', 1, false);
            public       postgres    false    233            �           0    0    promotion_seq    SEQUENCE SET     <   SELECT pg_catalog.setval('public.promotion_seq', 1, false);
            public       postgres    false    219            �           0    0    receipt_detail_seq    SEQUENCE SET     A   SELECT pg_catalog.setval('public.receipt_detail_seq', 1, false);
            public       postgres    false    252            �           0    0    receipt_seq    SEQUENCE SET     :   SELECT pg_catalog.setval('public.receipt_seq', 1, false);
            public       postgres    false    245            �           0    0    receipt_wash_bag_seq    SEQUENCE SET     C   SELECT pg_catalog.setval('public.receipt_wash_bag_seq', 1, false);
            public       postgres    false    251            �           0    0    service_type_branch_seq    SEQUENCE SET     F   SELECT pg_catalog.setval('public.service_type_branch_seq', 1, false);
            public       postgres    false    227            �           0    0    service_type_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public.service_type_seq', 1, false);
            public       postgres    false    225            �           0    0 	   staff_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.staff_seq', 1, false);
            public       postgres    false    205            �           0    0    staff_type_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.staff_type_seq', 1, false);
            public       postgres    false    197            �           0    0 	   store_seq    SEQUENCE SET     8   SELECT pg_catalog.setval('public.store_seq', 1, false);
            public       postgres    false    199            �           0    0    time_schedule_seq    SEQUENCE SET     @   SELECT pg_catalog.setval('public.time_schedule_seq', 1, false);
            public       postgres    false    235            �           0    0    unit_price_seq    SEQUENCE SET     =   SELECT pg_catalog.setval('public.unit_price_seq', 1, false);
            public       postgres    false    237            �           0    0    unit_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.unit_seq', 1, false);
            public       postgres    false    203            �           0    0    wash_bag_detail_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.wash_bag_detail_seq', 1, false);
            public       postgres    false    254            �           0    0    wash_bag_seq    SEQUENCE SET     ;   SELECT pg_catalog.setval('public.wash_bag_seq', 1, false);
            public       postgres    false    221            �           0    0    wash_seq    SEQUENCE SET     7   SELECT pg_catalog.setval('public.wash_seq', 1, false);
            public       postgres    false    239            �           0    0    washing_machine_seq    SEQUENCE SET     B   SELECT pg_catalog.setval('public.washing_machine_seq', 1, false);
            public       postgres    false    223            �           2606    19553    bill_detail bill_detail_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT bill_detail_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT bill_detail_pkey;
       public         postgres    false    257            �           2606    19519    bill bill_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT bill_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.bill DROP CONSTRAINT bill_pkey;
       public         postgres    false    255            _           2606    18860    branch branch_pkey 
   CONSTRAINT     P   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT branch_pkey PRIMARY KEY (id);
 <   ALTER TABLE ONLY public.branch DROP CONSTRAINT branch_pkey;
       public         postgres    false    200            i           2606    18924    color_group color_group_pkey 
   CONSTRAINT     Z   ALTER TABLE ONLY public.color_group
    ADD CONSTRAINT color_group_pkey PRIMARY KEY (id);
 F   ALTER TABLE ONLY public.color_group DROP CONSTRAINT color_group_pkey;
       public         postgres    false    210            k           2606    18935    color color_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.color
    ADD CONSTRAINT color_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.color DROP CONSTRAINT color_pkey;
       public         postgres    false    212            �           2606    19179 "   customer_order customer_order_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT customer_order_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT customer_order_pkey;
       public         postgres    false    246            {           2606    19040    customer customer_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.customer
    ADD CONSTRAINT customer_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.customer DROP CONSTRAINT customer_pkey;
       public         postgres    false    230            �           2606    19111    dry dry_pkey 
   CONSTRAINT     J   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT dry_pkey PRIMARY KEY (id);
 6   ALTER TABLE ONLY public.dry DROP CONSTRAINT dry_pkey;
       public         postgres    false    240            y           2606    19120    dryer dryer_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.dryer
    ADD CONSTRAINT dryer_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.dryer DROP CONSTRAINT dryer_pkey;
       public         postgres    false    228            e           2606    18904    label label_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.label DROP CONSTRAINT label_pkey;
       public         postgres    false    206            g           2606    18914    material material_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.material
    ADD CONSTRAINT material_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.material DROP CONSTRAINT material_pkey;
       public         postgres    false    208            �           2606    19239    order_detail order_detail_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT order_detail_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT order_detail_pkey;
       public         postgres    false    248            �           2606    19133    payment payment_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.payment DROP CONSTRAINT payment_pkey;
       public         postgres    false    242            o           2606    18960    product product_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.product
    ADD CONSTRAINT product_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.product DROP CONSTRAINT product_pkey;
       public         postgres    false    216            m           2606    18950    product_type product_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.product_type
    ADD CONSTRAINT product_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.product_type DROP CONSTRAINT product_type_pkey;
       public         postgres    false    214            q           2606    18975    promotion promotion_pkey 
   CONSTRAINT     V   ALTER TABLE ONLY public.promotion
    ADD CONSTRAINT promotion_pkey PRIMARY KEY (id);
 B   ALTER TABLE ONLY public.promotion DROP CONSTRAINT promotion_pkey;
       public         postgres    false    218            �           2606    19633 "   receipt_detail receipt_detail_pkey 
   CONSTRAINT     `   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT receipt_detail_pkey PRIMARY KEY (id);
 L   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT receipt_detail_pkey;
       public         postgres    false    259            �           2606    19524    receipt receipt_pkey 
   CONSTRAINT     R   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT receipt_pkey PRIMARY KEY (id);
 >   ALTER TABLE ONLY public.receipt DROP CONSTRAINT receipt_pkey;
       public         postgres    false    256            �           2606    19618 &   receipt_wash_bag receipt_wash_bag_pkey 
   CONSTRAINT     d   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT receipt_wash_bag_pkey PRIMARY KEY (id);
 P   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT receipt_wash_bag_pkey;
       public         postgres    false    258            w           2606    19000    service_type service_type_pkey 
   CONSTRAINT     \   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT service_type_pkey PRIMARY KEY (id);
 H   ALTER TABLE ONLY public.service_type DROP CONSTRAINT service_type_pkey;
       public         postgres    false    224            c           2606    18882    staff staff_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT staff_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.staff DROP CONSTRAINT staff_pkey;
       public         postgres    false    204            [           2606    18886    staff_type staff_type_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.staff_type
    ADD CONSTRAINT staff_type_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.staff_type DROP CONSTRAINT staff_type_pkey;
       public         postgres    false    196            ]           2606    18837    store store_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.store
    ADD CONSTRAINT store_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.store DROP CONSTRAINT store_pkey;
       public         postgres    false    198            }           2606    19063     time_schedule time_schedule_pkey 
   CONSTRAINT     ^   ALTER TABLE ONLY public.time_schedule
    ADD CONSTRAINT time_schedule_pkey PRIMARY KEY (id);
 J   ALTER TABLE ONLY public.time_schedule DROP CONSTRAINT time_schedule_pkey;
       public         postgres    false    234            a           2606    18872    unit unit_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.unit DROP CONSTRAINT unit_pkey;
       public         postgres    false    202                       2606    19070    unit_price unit_price_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT unit_price_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT unit_price_pkey;
       public         postgres    false    236            �           2606    19406 $   wash_bag_detail wash_bag_detail_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT wash_bag_detail_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT wash_bag_detail_pkey;
       public         postgres    false    253            s           2606    18985    wash_bag wash_bag_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.wash_bag
    ADD CONSTRAINT wash_bag_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.wash_bag DROP CONSTRAINT wash_bag_pkey;
       public         postgres    false    220            �           2606    19092    wash wash_pkey 
   CONSTRAINT     L   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT wash_pkey PRIMARY KEY (id);
 8   ALTER TABLE ONLY public.wash DROP CONSTRAINT wash_pkey;
       public         postgres    false    238            u           2606    19101 $   washing_machine washing_machine_pkey 
   CONSTRAINT     b   ALTER TABLE ONLY public.washing_machine
    ADD CONSTRAINT washing_machine_pkey PRIMARY KEY (id);
 N   ALTER TABLE ONLY public.washing_machine DROP CONSTRAINT washing_machine_pkey;
       public         postgres    false    222            �           2606    19594    bill fk_bill_customer_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id);
 B   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_customer_id;
       public       postgres    false    255    2939    230            �           2606    19554 "   bill_detail fk_bill_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_bill_id FOREIGN KEY (bill_id) REFERENCES public.bill(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_bill_id;
       public       postgres    false    255    257    2957            �           2606    19579 #   bill_detail fk_bill_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_color_id;
       public       postgres    false    2923    212    257            �           2606    19574 #   bill_detail fk_bill_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 M   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_label_id;
       public       postgres    false    257    206    2917            �           2606    19589 &   bill_detail fk_bill_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 P   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_material_id;
       public       postgres    false    257    208    2919            �           2606    19584 %   bill_detail fk_bill_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 O   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_product_id;
       public       postgres    false    216    2927    257            �           2606    19559 *   bill_detail fk_bill_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 T   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_service_type_id;
       public       postgres    false    2935    257    224            �           2606    19569 "   bill_detail fk_bill_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 L   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_unit_id;
       public       postgres    false    257    202    2913            �           2606    19564 (   bill_detail fk_bill_detail_unit_price_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.bill_detail
    ADD CONSTRAINT fk_bill_detail_unit_price_id FOREIGN KEY (unit_price_id) REFERENCES public.unit_price(id);
 R   ALTER TABLE ONLY public.bill_detail DROP CONSTRAINT fk_bill_detail_unit_price_id;
       public       postgres    false    257    236    2943            �           2606    19604    bill fk_bill_order_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 ?   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_order_id;
       public       postgres    false    2951    255    246            �           2606    19599    bill fk_bill_payment_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_payment_id FOREIGN KEY (payment_id) REFERENCES public.payment(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_payment_id;
       public       postgres    false    242    2949    255            �           2606    19609    bill fk_bill_receipt_id    FK CONSTRAINT     {   ALTER TABLE ONLY public.bill
    ADD CONSTRAINT fk_bill_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 A   ALTER TABLE ONLY public.bill DROP CONSTRAINT fk_bill_receipt_id;
       public       postgres    false    255    2959    256            �           2606    18892    staff fk_branch_id    FK CONSTRAINT     t   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 <   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_branch_id;
       public       postgres    false    2911    204    200            �           2606    18863    branch fk_branch_store_id    FK CONSTRAINT     y   ALTER TABLE ONLY public.branch
    ADD CONSTRAINT fk_branch_store_id FOREIGN KEY (store_id) REFERENCES public.store(id);
 C   ALTER TABLE ONLY public.branch DROP CONSTRAINT fk_branch_store_id;
       public       postgres    false    198    2909    200            �           2606    18938    color fk_color_color_group_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.color
    ADD CONSTRAINT fk_color_color_group_id FOREIGN KEY (color_group_id) REFERENCES public.color_group(id);
 G   ALTER TABLE ONLY public.color DROP CONSTRAINT fk_color_color_group_id;
       public       postgres    false    2921    212    210            �           2606    19187 *   customer_order fk_customer_order_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 T   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_branch_id;
       public       postgres    false    246    2911    200            �           2606    19182 ,   customer_order fk_customer_order_customer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id);
 V   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_customer_id;
       public       postgres    false    246    230    2939            �           2606    19212 1   customer_order fk_customer_order_delivery_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_delivery_time_id FOREIGN KEY (delivery_time_id) REFERENCES public.time_schedule(id);
 [   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_delivery_time_id;
       public       postgres    false    246    2941    234            �           2606    19202 +   customer_order fk_customer_order_payment_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_payment_id FOREIGN KEY (payment_id) REFERENCES public.payment(id);
 U   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_payment_id;
       public       postgres    false    242    246    2949            �           2606    19207 0   customer_order fk_customer_order_pick_up_time_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_pick_up_time_id FOREIGN KEY (pick_up_time_id) REFERENCES public.time_schedule(id);
 Z   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_pick_up_time_id;
       public       postgres    false    246    234    2941            �           2606    19192 ,   customer_order fk_customer_order_receiver_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_receiver_id FOREIGN KEY (receiver_id) REFERENCES public.staff(id);
 V   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_receiver_id;
       public       postgres    false    246    2915    204            �           2606    19197 +   customer_order fk_customer_order_shipper_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.customer_order
    ADD CONSTRAINT fk_customer_order_shipper_id FOREIGN KEY (shipper_id) REFERENCES public.staff(id);
 U   ALTER TABLE ONLY public.customer_order DROP CONSTRAINT fk_customer_order_shipper_id;
       public       postgres    false    246    2915    204            �           2606    19114    dry fk_dry_dry_bag_id    FK CONSTRAINT     z   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT fk_dry_dry_bag_id FOREIGN KEY (dry_bag_id) REFERENCES public.wash_bag(id);
 ?   ALTER TABLE ONLY public.dry DROP CONSTRAINT fk_dry_dry_bag_id;
       public       postgres    false    220    2931    240            �           2606    19121     dry fk_dry_dry_drying_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.dry
    ADD CONSTRAINT fk_dry_dry_drying_machine_id FOREIGN KEY (drying_machine_id) REFERENCES public.dryer(id);
 J   ALTER TABLE ONLY public.dry DROP CONSTRAINT fk_dry_dry_drying_machine_id;
       public       postgres    false    2937    240    228            �           2606    19028    dryer fk_dryer_branch_id    FK CONSTRAINT     z   ALTER TABLE ONLY public.dryer
    ADD CONSTRAINT fk_dryer_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 B   ALTER TABLE ONLY public.dryer DROP CONSTRAINT fk_dryer_branch_id;
       public       postgres    false    228    200    2911            �           2606    19242 %   order_detail fk_order_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_label_id;
       public       postgres    false    248    2917    206            �           2606    19247 %   order_detail fk_order_detail_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 O   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_order_id;
       public       postgres    false    246    248    2951            �           2606    19252 ,   order_detail fk_order_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 V   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_service_type_id;
       public       postgres    false    224    248    2935            �           2606    19262 $   order_detail fk_order_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 N   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_unit_id;
       public       postgres    false    248    2913    202            �           2606    19257 *   order_detail fk_order_detail_unit_price_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.order_detail
    ADD CONSTRAINT fk_order_detail_unit_price_id FOREIGN KEY (unit_price_id) REFERENCES public.unit_price(id);
 T   ALTER TABLE ONLY public.order_detail DROP CONSTRAINT fk_order_detail_unit_price_id;
       public       postgres    false    236    2943    248            �           2606    18963 "   product fk_product_product_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.product
    ADD CONSTRAINT fk_product_product_type_id FOREIGN KEY (producy_type_id) REFERENCES public.product_type(id);
 L   ALTER TABLE ONLY public.product DROP CONSTRAINT fk_product_product_type_id;
       public       postgres    false    214    2925    216            �           2606    19048 .   promotion_branch fk_promotion_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 X   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_branch_id;
       public       postgres    false    200    2911    232            �           2606    19054 1   promotion_branch fk_promotion_branch_promotion_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.promotion_branch
    ADD CONSTRAINT fk_promotion_branch_promotion_id FOREIGN KEY (promotion_id) REFERENCES public.promotion(id);
 [   ALTER TABLE ONLY public.promotion_branch DROP CONSTRAINT fk_promotion_branch_promotion_id;
       public       postgres    false    2929    232    218            �           2606    19526    receipt fk_receipt_customer_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_customer_id FOREIGN KEY (customer_id) REFERENCES public.customer(id);
 H   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_customer_id;
       public       postgres    false    230    256    2939            �           2606    19634 (   receipt_detail fk_receipt_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_bill_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_bill_id;
       public       postgres    false    2959    256    259            �           2606    19659 )   receipt_detail fk_receipt_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_color_id;
       public       postgres    false    2923    212    259            �           2606    19654 )   receipt_detail fk_receipt_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 S   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_label_id;
       public       postgres    false    2917    259    206            �           2606    19669 ,   receipt_detail fk_receipt_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 V   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_material_id;
       public       postgres    false    208    2919    259            �           2606    19664 +   receipt_detail fk_receipt_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 U   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_product_id;
       public       postgres    false    259    216    2927            �           2606    19639 0   receipt_detail fk_receipt_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 Z   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_service_type_id;
       public       postgres    false    2935    259    224            �           2606    19649 (   receipt_detail fk_receipt_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 R   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_unit_id;
       public       postgres    false    259    2913    202            �           2606    19644 .   receipt_detail fk_receipt_detail_unit_price_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_detail
    ADD CONSTRAINT fk_receipt_detail_unit_price_id FOREIGN KEY (unit_price_id) REFERENCES public.unit_price(id);
 X   ALTER TABLE ONLY public.receipt_detail DROP CONSTRAINT fk_receipt_detail_unit_price_id;
       public       postgres    false    236    2943    259            �           2606    19531    receipt fk_receipt_order_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_order_id FOREIGN KEY (order_id) REFERENCES public.customer_order(id);
 E   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_order_id;
       public       postgres    false    246    2951    256            �           2606    19541    receipt fk_receipt_receiver_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_receiver_id FOREIGN KEY (receiver_id) REFERENCES public.staff(id);
 H   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_receiver_id;
       public       postgres    false    256    204    2915            �           2606    19536    receipt fk_receipt_shipper_id    FK CONSTRAINT        ALTER TABLE ONLY public.receipt
    ADD CONSTRAINT fk_receipt_shipper_id FOREIGN KEY (shipper_id) REFERENCES public.staff(id);
 G   ALTER TABLE ONLY public.receipt DROP CONSTRAINT fk_receipt_shipper_id;
       public       postgres    false    256    2915    204            �           2606    19624 /   receipt_wash_bag fk_receipt_wash_bag_receipt_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT fk_receipt_wash_bag_receipt_id FOREIGN KEY (receipt_id) REFERENCES public.receipt(id);
 Y   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT fk_receipt_wash_bag_receipt_id;
       public       postgres    false    2959    258    256            �           2606    19619 0   receipt_wash_bag fk_receipt_wash_bag_wash_bag_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.receipt_wash_bag
    ADD CONSTRAINT fk_receipt_wash_bag_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 Z   ALTER TABLE ONLY public.receipt_wash_bag DROP CONSTRAINT fk_receipt_wash_bag_wash_bag_id;
       public       postgres    false    2931    258    220            �           2606    19013 4   service_type_branch fk_service_type_branch_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 ^   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_branch_id;
       public       postgres    false    226    2911    200            �           2606    19018 :   service_type_branch fk_service_type_branch_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type_branch
    ADD CONSTRAINT fk_service_type_branch_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 d   ALTER TABLE ONLY public.service_type_branch DROP CONSTRAINT fk_service_type_branch_service_type_id;
       public       postgres    false    224    2935    226            �           2606    19003 )   service_type fk_service_type_promotion_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT fk_service_type_promotion_id FOREIGN KEY (promotion_id) REFERENCES public.promotion(id);
 S   ALTER TABLE ONLY public.service_type DROP CONSTRAINT fk_service_type_promotion_id;
       public       postgres    false    218    224    2929            �           2606    19680 *   service_type fk_service_type_unit_price_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.service_type
    ADD CONSTRAINT fk_service_type_unit_price_id FOREIGN KEY (unit_price_id) REFERENCES public.unit_price(id);
 T   ALTER TABLE ONLY public.service_type DROP CONSTRAINT fk_service_type_unit_price_id;
       public       postgres    false    236    224    2943            �           2606    18887    staff fk_staff_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.staff
    ADD CONSTRAINT fk_staff_type_id FOREIGN KEY (staff_type_id) REFERENCES public.staff_type(id);
 @   ALTER TABLE ONLY public.staff DROP CONSTRAINT fk_staff_type_id;
       public       postgres    false    204    2907    196            �           2606    19073 #   unit_price fk_unit_price_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 M   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_product_id;
       public       postgres    false    236    216    2927            �           2606    19078 (   unit_price fk_unit_price_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 R   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_service_type_id;
       public       postgres    false    2935    224    236            �           2606    19083     unit_price fk_unit_price_unit_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.unit_price
    ADD CONSTRAINT fk_unit_price_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 J   ALTER TABLE ONLY public.unit_price DROP CONSTRAINT fk_unit_price_unit_id;
       public       postgres    false    2913    236    202            �           2606    19409 *   wash_bag_detail fk_wash_bag_detail_bill_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_bill_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_bill_id;
       public       postgres    false    253    2931    220            �           2606    19434 +   wash_bag_detail fk_wash_bag_detail_color_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_color_id FOREIGN KEY (color_id) REFERENCES public.color(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_color_id;
       public       postgres    false    253    2923    212            �           2606    19429 +   wash_bag_detail fk_wash_bag_detail_label_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_label_id FOREIGN KEY (label_id) REFERENCES public.label(id);
 U   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_label_id;
       public       postgres    false    2917    253    206            �           2606    19444 .   wash_bag_detail fk_wash_bag_detail_material_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_material_id FOREIGN KEY (material_id) REFERENCES public.material(id);
 X   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_material_id;
       public       postgres    false    208    2919    253            �           2606    19439 -   wash_bag_detail fk_wash_bag_detail_product_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_product_id FOREIGN KEY (product_id) REFERENCES public.product(id);
 W   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_product_id;
       public       postgres    false    2927    216    253            �           2606    19414 2   wash_bag_detail fk_wash_bag_detail_service_type_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_service_type_id FOREIGN KEY (service_type_id) REFERENCES public.service_type(id);
 \   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_service_type_id;
       public       postgres    false    253    2935    224            �           2606    19424 *   wash_bag_detail fk_wash_bag_detail_unit_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_unit_id FOREIGN KEY (unit_id) REFERENCES public.unit(id);
 T   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_unit_id;
       public       postgres    false    253    2913    202            �           2606    19419 0   wash_bag_detail fk_wash_bag_detail_unit_price_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash_bag_detail
    ADD CONSTRAINT fk_wash_bag_detail_unit_price_id FOREIGN KEY (unit_price_id) REFERENCES public.unit_price(id);
 Z   ALTER TABLE ONLY public.wash_bag_detail DROP CONSTRAINT fk_wash_bag_detail_unit_price_id;
       public       postgres    false    253    236    2943            �           2606    19095    wash fk_wash_wash_bag_id    FK CONSTRAINT     ~   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_bag_id FOREIGN KEY (wash_bag_id) REFERENCES public.wash_bag(id);
 B   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_bag_id;
       public       postgres    false    220    2931    238            �           2606    19102 $   wash fk_wash_wash_washing_machine_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.wash
    ADD CONSTRAINT fk_wash_wash_washing_machine_id FOREIGN KEY (washing_machine_id) REFERENCES public.washing_machine(id);
 N   ALTER TABLE ONLY public.wash DROP CONSTRAINT fk_wash_wash_washing_machine_id;
       public       postgres    false    238    2933    222            �           2606    19507 ,   washing_machine fk_washing_machine_branch_id    FK CONSTRAINT     �   ALTER TABLE ONLY public.washing_machine
    ADD CONSTRAINT fk_washing_machine_branch_id FOREIGN KEY (branch_id) REFERENCES public.branch(id);
 V   ALTER TABLE ONLY public.washing_machine DROP CONSTRAINT fk_washing_machine_branch_id;
       public       postgres    false    222    200    2911            �      x������ � �      �      x������ � �      U      x������ � �      a      x������ � �      _      x������ � �      s   �   x���;
�0E�z�
W ���\�+H�AE0~�oD��&_�a`r�ˤ2Ƕ/�_�m;ͱY���TB;��!��4ˋ�rH^���эP�It���$ '9���B�(�DA
b	�&��!L�iC��S�0	���a�`X"�!N^aI�      �   <   x�3��/JI-���7��#	q!�%M7�1�ZM��jJ�V3򵚓�Ղ|���k����� N��      }      x������ � �      q      x������ � �      [      x������ � �      ]      x������ � �      �      x������ � �            x������ � �      e      x������ � �      c      x������ � �      g      x������ � �      u      x������ � �      �      x������ � �      �      x������ � �      �      x������ � �      m      x������ � �      o      x������ � �      Y      x������ � �      Q      x������ � �      S      x������ � �      w      x������ � �      W      x������ � �      y      x������ � �      {      x������ � �      i      x������ � �      �      x������ � �      k      x������ � �     