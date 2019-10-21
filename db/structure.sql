--
-- PostgreSQL database dump
--

-- Dumped from database version 12.0
-- Dumped by pg_dump version 12.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: games; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.games (
    id integer NOT NULL,
    date date NOT NULL,
    home_team_id integer NOT NULL,
    away_team_id integer NOT NULL,
    season character varying(10)
);


ALTER TABLE public.games OWNER TO nbauser;

--
-- Name: games_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.games_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.games_id_seq OWNER TO nbauser;

--
-- Name: games_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.games_id_seq OWNED BY public.games.id;


--
-- Name: players; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.players (
    id integer NOT NULL,
    dk_name character varying(100),
    fd_name character varying(100),
    br_name character varying(100),
    rg_name character varying(100),
    current_team_id integer,
    br2_name character varying(100),
    fte_name character varying(100),
    sa_name character varying(100)
);


ALTER TABLE public.players OWNER TO nbauser;

--
-- Name: players_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.players_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.players_id_seq OWNER TO nbauser;

--
-- Name: players_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.players_id_seq OWNED BY public.players.id;


--
-- Name: stat_lines; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.stat_lines (
    id integer NOT NULL,
    player_id integer NOT NULL,
    team_id integer NOT NULL,
    game_id integer NOT NULL,
    dk_positions character varying(15),
    fd_positions character varying(15),
    dk_salary integer,
    fd_salary integer,
    dk_points numeric,
    fd_points numeric,
    stats jsonb,
    date date,
    minutes numeric DEFAULT 0.0
);


ALTER TABLE public.stat_lines OWNER TO nbauser;

--
-- Name: stat_lines_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.stat_lines_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.stat_lines_id_seq OWNER TO nbauser;

--
-- Name: stat_lines_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.stat_lines_id_seq OWNED BY public.stat_lines.id;


--
-- Name: teams; Type: TABLE; Schema: public; Owner: nbauser
--

CREATE TABLE public.teams (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    abbrv character varying(10) NOT NULL,
    rg_abbrv character varying(10) NOT NULL,
    br_abbrv character varying(10)
);


ALTER TABLE public.teams OWNER TO nbauser;

--
-- Name: teams_id_seq; Type: SEQUENCE; Schema: public; Owner: nbauser
--

CREATE SEQUENCE public.teams_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.teams_id_seq OWNER TO nbauser;

--
-- Name: teams_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: nbauser
--

ALTER SEQUENCE public.teams_id_seq OWNED BY public.teams.id;


--
-- Name: games id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games ALTER COLUMN id SET DEFAULT nextval('public.games_id_seq'::regclass);


--
-- Name: players id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players ALTER COLUMN id SET DEFAULT nextval('public.players_id_seq'::regclass);


--
-- Name: stat_lines id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines ALTER COLUMN id SET DEFAULT nextval('public.stat_lines_id_seq'::regclass);


--
-- Name: teams id; Type: DEFAULT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams ALTER COLUMN id SET DEFAULT nextval('public.teams_id_seq'::regclass);


--
-- Name: games games_date_home_team_away_team; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_date_home_team_away_team UNIQUE (date, home_team_id, away_team_id);


--
-- Name: games games_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_pkey PRIMARY KEY (id);


--
-- Name: players players_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_pkey PRIMARY KEY (id);


--
-- Name: players players_rg_name_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_rg_name_key UNIQUE (rg_name);


--
-- Name: stat_lines stat_lines_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_pkey PRIMARY KEY (id);


--
-- Name: stat_lines stat_lines_player_id_game_id_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_player_id_game_id_key UNIQUE (player_id, game_id);


--
-- Name: teams teams_abbrv_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_abbrv_key UNIQUE (abbrv);


--
-- Name: teams teams_name_abbrv_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_abbrv_key UNIQUE (name, abbrv);


--
-- Name: teams teams_name_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_name_key UNIQUE (name);


--
-- Name: teams teams_pkey; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_pkey PRIMARY KEY (id);


--
-- Name: teams teams_rg_abbrv_key; Type: CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.teams
    ADD CONSTRAINT teams_rg_abbrv_key UNIQUE (rg_abbrv);


--
-- Name: players_br_name_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX players_br_name_idx ON public.players USING btree (br_name);


--
-- Name: stat_lines_date_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_date_idx ON public.stat_lines USING btree (date);


--
-- Name: stat_lines_minutes_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_minutes_idx ON public.stat_lines USING btree (minutes);


--
-- Name: stat_lines_player_id_date_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_player_id_date_idx ON public.stat_lines USING btree (player_id, date);


--
-- Name: stat_lines_player_id_date_minutes_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_player_id_date_minutes_idx ON public.stat_lines USING btree (player_id, date, minutes);


--
-- Name: stat_lines_player_id_idx; Type: INDEX; Schema: public; Owner: nbauser
--

CREATE INDEX stat_lines_player_id_idx ON public.stat_lines USING btree (player_id);


--
-- Name: games games_away_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_away_team_id_fkey FOREIGN KEY (away_team_id) REFERENCES public.teams(id);


--
-- Name: games games_home_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.games
    ADD CONSTRAINT games_home_team_id_fkey FOREIGN KEY (home_team_id) REFERENCES public.teams(id);


--
-- Name: players players_current_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.players
    ADD CONSTRAINT players_current_team_id_fkey FOREIGN KEY (current_team_id) REFERENCES public.teams(id);


--
-- Name: stat_lines stat_lines_game_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_game_id_fkey FOREIGN KEY (game_id) REFERENCES public.games(id);


--
-- Name: stat_lines stat_lines_player_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_player_id_fkey FOREIGN KEY (player_id) REFERENCES public.players(id);


--
-- Name: stat_lines stat_lines_team_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: nbauser
--

ALTER TABLE ONLY public.stat_lines
    ADD CONSTRAINT stat_lines_team_id_fkey FOREIGN KEY (team_id) REFERENCES public.teams(id);


--
-- PostgreSQL database dump complete
--

