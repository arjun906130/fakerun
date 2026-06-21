# ============================================================
# Makefile â€” Development shortcuts for CLUTCH RUN
# ============================================================

.PHONY: install migrate static run test lint seed reset-db

install:
	pip install -r requirements.txt

migrate:
	python manage.py migrate

static:
	python manage.py collectstatic --noinput

run:
	python manage.py runserver

test:
	python manage.py test runner --verbosity=2

lint:
	python -m flake8 runner/ fakerun_project/ --max-line-length=120

seed:
	python manage.py seed_scores --count 30

reset-db:
	python manage.py reset_leaderboard --confirm

setup: install migrate static
	@echo "âœ… Dev environment ready. Run '\''make run'\'' to start the server."
