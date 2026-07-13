from datetime import datetime

from pydantic import BaseModel, Field

from app.models import TaskStatus


class TaskBase(BaseModel):
    title: str = Field(min_length=1, max_length=160)
    description: str | None = None
    status: TaskStatus = TaskStatus.todo
    owner: str | None = Field(default=None, max_length=120)


class TaskCreate(TaskBase):
    pass


class TaskUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=160)
    description: str | None = None
    status: TaskStatus | None = None
    owner: str | None = Field(default=None, max_length=120)


class TaskRead(TaskBase):
    id: int
    created_at: datetime
    updated_at: datetime

    model_config = {"from_attributes": True}
