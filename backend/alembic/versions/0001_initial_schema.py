from collections.abc import Sequence

import geoalchemy2
import sqlalchemy as sa
from alembic import op
from sqlalchemy.dialects import postgresql

revision: str = "0001_initial_schema"
down_revision: str | None = None
branch_labels: Sequence[str] | None = None
depends_on: Sequence[str] | None = None


def upgrade() -> None:
    op.execute("CREATE EXTENSION IF NOT EXISTS postgis;")

    op.create_table(
        "users",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column("email", sa.String(length=255), nullable=False),
        sa.Column("hashed_password", sa.String(length=255), nullable=False),
        sa.Column("nickname", sa.String(length=100), nullable=False),
        sa.Column("rating_points", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("region", sa.String(length=100), nullable=False, server_default="Main Region"),
        sa.Column("is_oopt_staff", sa.Boolean(), nullable=False, server_default=sa.false()),
        sa.Column("avatar_url", sa.String(length=500), nullable=True),
        sa.Column("spots_found_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column("spots_cleaned_count", sa.Integer(), nullable=False, server_default="0"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    op.create_table(
        "pollution_spots",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "reporter_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id"),
            nullable=True,
        ),
        sa.Column(
            "cleaner_id",
            postgresql.UUID(as_uuid=True),
            sa.ForeignKey("users.id"),
            nullable=True,
        ),
        sa.Column(
            "location",
            geoalchemy2.types.Geometry(geometry_type="POINT", srid=4326),
            nullable=False,
        ),
        sa.Column("pollution_score_before", sa.Integer(), nullable=True),
        sa.Column("pollution_score_after", sa.Integer(), nullable=True),
        sa.Column("detected_materials", postgresql.ARRAY(sa.String()), nullable=True),
        sa.Column("photo_before_url", sa.String(), nullable=False),
        sa.Column("photo_after_url", sa.String(), nullable=True),
        sa.Column("status", sa.String(length=50), nullable=False, server_default="ACTIVE"),
        sa.Column(
            "created_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.Column(
            "updated_at",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
        sa.CheckConstraint(
            "pollution_score_before BETWEEN 0 AND 100", name="ck_score_before_range"
        ),
        sa.CheckConstraint(
            "pollution_score_after BETWEEN 0 AND 100", name="ck_score_after_range"
        ),
    )

    op.create_table(
        "leaderboard_snapshots",
        sa.Column("id", postgresql.UUID(as_uuid=True), primary_key=True),
        sa.Column(
            "user_id", postgresql.UUID(as_uuid=True), sa.ForeignKey("users.id"), nullable=False
        ),
        sa.Column("region", sa.String(length=100), nullable=False),
        sa.Column("rank_position", sa.Integer(), nullable=False),
        sa.Column("rating_points", sa.Integer(), nullable=False),
        sa.Column(
            "snapshot_date",
            sa.DateTime(timezone=True),
            server_default=sa.text("CURRENT_TIMESTAMP"),
            nullable=False,
        ),
    )
    op.create_index("ix_leaderboard_region", "leaderboard_snapshots", ["region"])
    op.create_index("ix_leaderboard_date", "leaderboard_snapshots", ["snapshot_date"])


def downgrade() -> None:
    op.drop_index("ix_leaderboard_date", table_name="leaderboard_snapshots")
    op.drop_index("ix_leaderboard_region", table_name="leaderboard_snapshots")
    op.drop_table("leaderboard_snapshots")

    op.drop_table("pollution_spots")

    op.drop_index("ix_users_email", table_name="users")
    op.drop_table("users")