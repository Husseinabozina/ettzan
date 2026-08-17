# Proposed API contracts

The UI is backend-agnostic. A production API can expose the following resources:

## Authentication

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/forgot-password`

## Coaches and sessions

- `GET /coaches?specialty=&rating=&page=`
- `GET /coaches/{coachId}`
- `GET /coaches/{coachId}/availability?from=&to=`
- `POST /sessions`
- `GET /sessions?status=upcoming|completed`
- `PATCH /sessions/{sessionId}/reschedule`

## Growth

- `GET|POST /goals`
- `PATCH /goals/{goalId}`
- `GET|POST /habits`
- `POST /habits/{habitId}/check-ins`
- `GET /plans/daily?date=`

## Journal and analytics

- `GET|POST /journal-entries`
- `GET /analytics/progress?range=30d`
- `GET /sessions/{sessionId}/notes`
- `GET|POST /conversations/{conversationId}/messages`

## Content and account

- `GET /resources?type=&category=`
- `GET /notifications`
- `PATCH /notifications/{notificationId}/read`
- `GET /subscriptions/plans`
- `POST /subscriptions/checkout`
- `GET|PATCH /profile`
- `GET|PATCH /settings`

Recommended response envelope:

```json
{
  "data": {},
  "meta": {"page": 1, "pageSize": 20, "total": 1},
  "error": null
}
```
