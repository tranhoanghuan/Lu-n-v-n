PGDMP                     
    v            db_21102018    10.4    10.4     `           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                       false            a           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                       false            b           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                       false                       1259    47157    env_var    TABLE     ~   CREATE TABLE public.env_var (
    key_name character varying,
    value_key character varying(255),
    id bigint NOT NULL
);
    DROP TABLE public.env_var;
       public         postgres    false            c           0    0    TABLE env_var    ACL     J   GRANT SELECT,INSERT,UPDATE ON TABLE public.env_var TO auth_authenticated;
            public       postgres    false    276                       1259    47155    ENV_VAR_id_seq    SEQUENCE     y   CREATE SEQUENCE public."ENV_VAR_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 '   DROP SEQUENCE public."ENV_VAR_id_seq";
       public       postgres    false    276            d           0    0    ENV_VAR_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public."ENV_VAR_id_seq" OWNED BY public.env_var.id;
            public       postgres    false    275            �           2604    47160 
   env_var id    DEFAULT     j   ALTER TABLE ONLY public.env_var ALTER COLUMN id SET DEFAULT nextval('public."ENV_VAR_id_seq"'::regclass);
 9   ALTER TABLE public.env_var ALTER COLUMN id DROP DEFAULT;
       public       postgres    false    275    276    276            ]          0    47157    env_var 
   TABLE DATA               :   COPY public.env_var (key_name, value_key, id) FROM stdin;
    public       postgres    false    276   �	       e           0    0    ENV_VAR_id_seq    SEQUENCE SET     ?   SELECT pg_catalog.setval('public."ENV_VAR_id_seq"', 1, false);
            public       postgres    false    275            �           2606    47165    env_var ENV_VAR_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.env_var
    ADD CONSTRAINT "ENV_VAR_pkey" PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.env_var DROP CONSTRAINT "ENV_VAR_pkey";
       public         postgres    false    276            ]   9   x���u�q
�4�4�
q]�\8�9� �� g��`NS����"Nc�=... ��r     