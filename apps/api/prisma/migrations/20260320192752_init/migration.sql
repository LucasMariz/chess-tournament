-- CreateEnum
CREATE TYPE "Role" AS ENUM ('ADMIN', 'ORGANIZER', 'ARBITER', 'PLAYER');

-- CreateEnum
CREATE TYPE "TournamentFormat" AS ENUM ('SWISS', 'ROUND_ROBIN', 'KNOCKOUT');

-- CreateEnum
CREATE TYPE "TournamentStatus" AS ENUM ('DRAFT', 'REGISTRATION', 'IN_PROGRESS', 'FINISHED', 'CANCELLED');

-- CreateEnum
CREATE TYPE "RoundStatus" AS ENUM ('PENDING', 'IN_PROGRESS', 'FINISHED');

-- CreateEnum
CREATE TYPE "GameResult" AS ENUM ('WHITE_WINS', 'BLACK_WINS', 'DRAW', 'FORFEIT_WHITE', 'FORFEIT_BLACK', 'DOUBLE_FORFEIT', 'IN_PROGRESS');

-- CreateEnum
CREATE TYPE "GameTermination" AS ENUM ('CHECKMATE', 'RESIGNATION', 'TIMEOUT', 'STALEMATE', 'INSUFFICIENT_MATERIAL', 'THREEFOLD_REPETITION', 'FIFTY_MOVE_RULE', 'AGREEMENT', 'FORFEIT');

-- CreateEnum
CREATE TYPE "BracketSide" AS ENUM ('UPPER', 'LOWER');

-- CreateTable
CREATE TABLE "users" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "password_hash" TEXT NOT NULL,
    "role" "Role" NOT NULL DEFAULT 'PLAYER',
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "users_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "players" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "full_name" TEXT NOT NULL,
    "fide_id" TEXT,
    "elo_rating" INTEGER NOT NULL DEFAULT 1200,
    "federation" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "players_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tournaments" (
    "id" TEXT NOT NULL,
    "organizer_id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "description" TEXT,
    "format" "TournamentFormat" NOT NULL,
    "status" "TournamentStatus" NOT NULL DEFAULT 'DRAFT',
    "max_players" INTEGER NOT NULL,
    "num_rounds" INTEGER NOT NULL,
    "time_control_minutes" INTEGER NOT NULL,
    "time_increment_seconds" INTEGER NOT NULL DEFAULT 0,
    "start_date" TIMESTAMP(3),
    "end_date" TIMESTAMP(3),
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tournaments_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "tournament_players" (
    "id" TEXT NOT NULL,
    "tournament_id" TEXT NOT NULL,
    "player_id" TEXT NOT NULL,
    "seed" INTEGER,
    "initial_rating" INTEGER NOT NULL,
    "score" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "buchholz" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "sonneborn_berger" DOUBLE PRECISION NOT NULL DEFAULT 0,
    "rank" INTEGER,
    "registered_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "tournament_players_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "rounds" (
    "id" TEXT NOT NULL,
    "tournament_id" TEXT NOT NULL,
    "round_number" INTEGER NOT NULL,
    "status" "RoundStatus" NOT NULL DEFAULT 'PENDING',
    "starts_at" TIMESTAMP(3),
    "ends_at" TIMESTAMP(3),

    CONSTRAINT "rounds_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "games" (
    "id" TEXT NOT NULL,
    "round_id" TEXT NOT NULL,
    "tournament_player_white_id" TEXT NOT NULL,
    "tournament_player_black_id" TEXT,
    "result" "GameResult" NOT NULL DEFAULT 'IN_PROGRESS',
    "termination" "GameTermination",
    "pgn" TEXT,
    "moves_count" INTEGER,
    "started_at" TIMESTAMP(3),
    "ended_at" TIMESTAMP(3),

    CONSTRAINT "games_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "swiss_pairing_configs" (
    "id" TEXT NOT NULL,
    "tournament_id" TEXT NOT NULL,
    "pairing_system" TEXT NOT NULL DEFAULT 'DUTCH',
    "accelerated" BOOLEAN NOT NULL DEFAULT false,
    "bye_score_half" BOOLEAN NOT NULL DEFAULT true,

    CONSTRAINT "swiss_pairing_configs_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "knockout_brackets" (
    "id" TEXT NOT NULL,
    "tournament_id" TEXT NOT NULL,
    "total_rounds" INTEGER NOT NULL,
    "has_third_place_match" BOOLEAN NOT NULL DEFAULT false,
    "double_elimination" BOOLEAN NOT NULL DEFAULT false,

    CONSTRAINT "knockout_brackets_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "bracket_slots" (
    "id" TEXT NOT NULL,
    "bracket_id" TEXT NOT NULL,
    "game_id" TEXT,
    "bracket_round" INTEGER NOT NULL,
    "position" INTEGER NOT NULL,
    "side" "BracketSide" NOT NULL DEFAULT 'UPPER',
    "winner_tp_id" TEXT,

    CONSTRAINT "bracket_slots_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "users_email_key" ON "users"("email");

-- CreateIndex
CREATE UNIQUE INDEX "players_user_id_key" ON "players"("user_id");

-- CreateIndex
CREATE UNIQUE INDEX "players_fide_id_key" ON "players"("fide_id");

-- CreateIndex
CREATE UNIQUE INDEX "tournament_players_tournament_id_player_id_key" ON "tournament_players"("tournament_id", "player_id");

-- CreateIndex
CREATE UNIQUE INDEX "rounds_tournament_id_round_number_key" ON "rounds"("tournament_id", "round_number");

-- CreateIndex
CREATE UNIQUE INDEX "swiss_pairing_configs_tournament_id_key" ON "swiss_pairing_configs"("tournament_id");

-- CreateIndex
CREATE UNIQUE INDEX "knockout_brackets_tournament_id_key" ON "knockout_brackets"("tournament_id");

-- CreateIndex
CREATE UNIQUE INDEX "bracket_slots_game_id_key" ON "bracket_slots"("game_id");

-- CreateIndex
CREATE UNIQUE INDEX "bracket_slots_bracket_id_bracket_round_position_side_key" ON "bracket_slots"("bracket_id", "bracket_round", "position", "side");

-- AddForeignKey
ALTER TABLE "players" ADD CONSTRAINT "players_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournaments" ADD CONSTRAINT "tournaments_organizer_id_fkey" FOREIGN KEY ("organizer_id") REFERENCES "users"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournament_players" ADD CONSTRAINT "tournament_players_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournaments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "tournament_players" ADD CONSTRAINT "tournament_players_player_id_fkey" FOREIGN KEY ("player_id") REFERENCES "players"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "rounds" ADD CONSTRAINT "rounds_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournaments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "games" ADD CONSTRAINT "games_round_id_fkey" FOREIGN KEY ("round_id") REFERENCES "rounds"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "games" ADD CONSTRAINT "games_tournament_player_white_id_fkey" FOREIGN KEY ("tournament_player_white_id") REFERENCES "tournament_players"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "games" ADD CONSTRAINT "games_tournament_player_black_id_fkey" FOREIGN KEY ("tournament_player_black_id") REFERENCES "tournament_players"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "swiss_pairing_configs" ADD CONSTRAINT "swiss_pairing_configs_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournaments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "knockout_brackets" ADD CONSTRAINT "knockout_brackets_tournament_id_fkey" FOREIGN KEY ("tournament_id") REFERENCES "tournaments"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bracket_slots" ADD CONSTRAINT "bracket_slots_bracket_id_fkey" FOREIGN KEY ("bracket_id") REFERENCES "knockout_brackets"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bracket_slots" ADD CONSTRAINT "bracket_slots_game_id_fkey" FOREIGN KEY ("game_id") REFERENCES "games"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "bracket_slots" ADD CONSTRAINT "bracket_slots_winner_tp_id_fkey" FOREIGN KEY ("winner_tp_id") REFERENCES "tournament_players"("id") ON DELETE SET NULL ON UPDATE CASCADE;
