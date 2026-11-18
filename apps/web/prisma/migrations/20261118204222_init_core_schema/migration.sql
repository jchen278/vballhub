-- CreateEnum
CREATE TYPE "EventType" AS ENUM ('tournament', 'league', 'drop_in');

-- CreateEnum
CREATE TYPE "Surface" AS ENUM ('indoor', 'beach', 'grass');

-- CreateEnum
CREATE TYPE "TeamSize" AS ENUM ('6s', '4s', '2s', 'other');

-- CreateEnum
CREATE TYPE "Format" AS ENUM ('coed', 'mens', 'womens', 'reverse_coed', 'other');

-- CreateEnum
CREATE TYPE "PriceUnit" AS ENUM ('per_team', 'per_player');

-- CreateEnum
CREATE TYPE "RegistrationStatus" AS ENUM ('upcoming', 'open', 'waitlist', 'sold_out');

-- CreateEnum
CREATE TYPE "SubmissionStatus" AS ENUM ('pending', 'published', 'expired');

-- CreateTable
CREATE TABLE "Venue" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "address" TEXT NOT NULL,
    "neighborhood" TEXT,
    "latitude" DOUBLE PRECISION NOT NULL,
    "longitude" DOUBLE PRECISION NOT NULL,
    "surface" "Surface",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Venue_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Event" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "description" TEXT,
    "organizerName" TEXT,
    "eventType" "EventType" NOT NULL,
    "surface" "Surface" NOT NULL,
    "registrationStatus" "RegistrationStatus" NOT NULL DEFAULT 'upcoming',
    "registrationUrl" TEXT,
    "registrationOpensAt" TIMESTAMP(3),
    "registrationDeadline" TIMESTAMP(3),
    "startDate" TIMESTAMP(3) NOT NULL,
    "endDate" TIMESTAMP(3) NOT NULL,
    "startTime" TEXT,
    "endTime" TEXT,
    "dayOfWeek" TEXT,
    "posterUrl" TEXT,
    "venueId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Event_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "EventDivision" (
    "id" TEXT NOT NULL,
    "eventId" TEXT NOT NULL,
    "displayLabel" TEXT NOT NULL,
    "skillScore" INTEGER NOT NULL,
    "teamSize" "TeamSize" NOT NULL,
    "format" "Format" NOT NULL,
    "price" DOUBLE PRECISION,
    "priceUnit" "PriceUnit",
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "EventDivision_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Submission" (
    "id" TEXT NOT NULL,
    "status" "SubmissionStatus" NOT NULL DEFAULT 'pending',
    "title" TEXT NOT NULL,
    "organizerName" TEXT,
    "contactEmail" TEXT,
    "eventType" "EventType",
    "surface" "Surface",
    "startDate" TIMESTAMP(3),
    "endDate" TIMESTAMP(3),
    "registrationUrl" TEXT,
    "rawPayloadJson" JSONB,
    "posterUrl" TEXT,
    "venueId" TEXT,
    "unverifiedVenueRaw" TEXT,
    "adminNotes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Submission_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Venue_name_key" ON "Venue"("name");

-- CreateIndex
CREATE INDEX "Event_startDate_endDate_idx" ON "Event"("startDate", "endDate");

-- CreateIndex
CREATE INDEX "Event_eventType_surface_registrationStatus_idx" ON "Event"("eventType", "surface", "registrationStatus");

-- CreateIndex
CREATE INDEX "Submission_status_idx" ON "Submission"("status");

-- AddForeignKey
ALTER TABLE "Event" ADD CONSTRAINT "Event_venueId_fkey" FOREIGN KEY ("venueId") REFERENCES "Venue"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "EventDivision" ADD CONSTRAINT "EventDivision_eventId_fkey" FOREIGN KEY ("eventId") REFERENCES "Event"("id") ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Submission" ADD CONSTRAINT "Submission_venueId_fkey" FOREIGN KEY ("venueId") REFERENCES "Venue"("id") ON DELETE SET NULL ON UPDATE CASCADE;
