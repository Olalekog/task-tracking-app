import React, { useEffect, useMemo, useState } from "react";
import { createRoot } from "react-dom/client";
import {
  CheckCircle2,
  Circle,
  Clock3,
  Columns3,
  ListChecks,
  Plus,
  Table2,
  Trash2,
} from "lucide-react";
import "./styles.css";

const API_URL = import.meta.env.VITE_API_URL || "";
const statuses = ["todo", "in_progress", "done"];
const statusMeta = {
  todo: {
    label: "To do",
    helper: "Ready to be picked up",
    icon: Circle,
  },
  in_progress: {
    label: "In progress",
    helper: "Currently moving",
    icon: Clock3,
  },
  done: {
    label: "Done",
    helper: "Completed work",
    icon: CheckCircle2,
  },
};

function statusLabel(status) {
  return statusMeta[status]?.label || status.replace("_", " ");
}

function App() {
  const [tasks, setTasks] = useState([]);
  const [error, setError] = useState("");
  const [form, setForm] = useState({ title: "", description: "", owner: "" });
  const [view, setView] = useState("table");

  const groupedTasks = useMemo(
    () =>
      tasks.reduce((groups, task) => {
        groups[task.status] = [...(groups[task.status] || []), task];
        return groups;
      }, {}),
    [tasks],
  );

  async function loadTasks() {
    setError("");
    try {
      const response = await fetch(`${API_URL}/api/tasks`);
      if (!response.ok) throw new Error("Unable to load tasks");
      setTasks(await response.json());
    } catch (err) {
      setError(err.message);
    }
  }

  async function createTask(event) {
    event.preventDefault();
    if (!form.title.trim()) return;

    const response = await fetch(`${API_URL}/api/tasks`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        ...form,
        title: form.title.trim(),
        status: "todo",
      }),
    });

    if (response.ok) {
      setForm({ title: "", description: "", owner: "" });
      await loadTasks();
    }
  }

  async function updateStatus(task, status) {
    await fetch(`${API_URL}/api/tasks/${task.id}`, {
      method: "PATCH",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ status }),
    });
    await loadTasks();
  }

  async function deleteTask(taskId) {
    await fetch(`${API_URL}/api/tasks/${taskId}`, { method: "DELETE" });
    await loadTasks();
  }

  useEffect(() => {
    loadTasks();
  }, []);

  return (
    <main className="app-shell">
      <section className="topbar">
        <div>
          <p className="eyebrow">Delivery register</p>
          <h1>Task Tracking App</h1>
        </div>
        <div className="health">FastAPI + React + MySQL</div>
      </section>

      <form className="task-form" onSubmit={createTask}>
        <input
          aria-label="Task title"
          placeholder="Add a task"
          value={form.title}
          onChange={(event) => setForm({ ...form, title: event.target.value })}
        />
        <input
          aria-label="Owner"
          placeholder="Owner"
          value={form.owner}
          onChange={(event) => setForm({ ...form, owner: event.target.value })}
        />
        <input
          aria-label="Description"
          placeholder="Description"
          value={form.description}
          onChange={(event) => setForm({ ...form, description: event.target.value })}
        />
        <button type="submit" aria-label="Create task">
          <Plus size={18} />
          Add
        </button>
      </form>

      {error && <p className="error">{error}</p>}

      <div className="view-tabs" aria-label="Task view">
        <button
          className={view === "table" ? "active" : ""}
          onClick={() => setView("table")}
          type="button"
        >
          <Table2 size={18} />
          Table
        </button>
        <button
          className={view === "kanban" ? "active" : ""}
          onClick={() => setView("kanban")}
          type="button"
        >
          <Columns3 size={18} />
          Kanban
        </button>
      </div>

      {view === "table" && (
        <section className="table-shell" aria-label="Task register">
          <table className="task-table">
            <thead>
              <tr>
                <th>ITEM Number</th>
                <th>Description</th>
                <th>Details</th>
                <th>Status</th>
                <th>Owner</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              {tasks.length === 0 && (
                <tr>
                  <td className="empty-row" colSpan="6">
                    No tasks added yet.
                  </td>
                </tr>
              )}
              {tasks.map((task, index) => (
                <tr key={task.id}>
                  <td className="item-number">{String(index + 1).padStart(3, "0")}</td>
                  <td>
                    <strong>{task.title}</strong>
                  </td>
                  <td>{task.description || "No details provided"}</td>
                  <td>
                    <span className={`status-pill ${task.status}`}>{statusLabel(task.status)}</span>
                  </td>
                  <td>{task.owner || "Unassigned"}</td>
                  <td>
                    <TaskActions task={task} updateStatus={updateStatus} deleteTask={deleteTask} />
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </section>
      )}

      {view === "kanban" && (
        <section className="board" aria-label="Kanban board">
          {statuses.map((status) => {
            const tasksInColumn = groupedTasks[status] || [];
            const StatusIcon = statusMeta[status].icon;

            return (
              <div className={`column ${status}`} key={status}>
                <div className="column-header">
                  <div className="column-title">
                    <span className="column-icon">
                      <StatusIcon size={18} />
                    </span>
                    <div>
                      <h2>{statusLabel(status)}</h2>
                      <p>{statusMeta[status].helper}</p>
                    </div>
                  </div>
                  <span className="column-count">{tasksInColumn.length}</span>
                </div>

                <div className="task-list">
                  {tasksInColumn.length === 0 && (
                    <div className="empty-column">
                      <ListChecks size={22} />
                      <span>No tasks here</span>
                    </div>
                  )}

                  {tasksInColumn.map((task) => (
                    <article className="task-card" key={task.id}>
                      <div className="task-card-header">
                        <span className={`status-dot ${task.status}`} />
                        <span className="status-text">{statusLabel(task.status)}</span>
                      </div>
                      <div className="task-content">
                        <h3>{task.title}</h3>
                        {task.description && <p>{task.description}</p>}
                      </div>
                      <div className="task-footer">
                        <span>{task.owner || "Unassigned"}</span>
                        <TaskActions task={task} updateStatus={updateStatus} deleteTask={deleteTask} />
                      </div>
                    </article>
                  ))}
                </div>
              </div>
            );
          })}
        </section>
      )}
    </main>
  );
}

function TaskActions({ task, updateStatus, deleteTask }) {
  return (
    <div className="task-actions">
      {statuses.map((nextStatus) => (
        <button
          key={nextStatus}
          aria-label={`Move ${task.title} to ${statusLabel(nextStatus)}`}
          title={`Move to ${statusLabel(nextStatus)}`}
          className={nextStatus === task.status ? "active" : ""}
          onClick={() => updateStatus(task, nextStatus)}
          type="button"
        >
          {nextStatus === "done" ? <CheckCircle2 size={16} /> : <Circle size={16} />}
        </button>
      ))}
      <button
        aria-label={`Delete ${task.title}`}
        className="danger"
        title="Delete task"
        onClick={() => deleteTask(task.id)}
        type="button"
      >
        <Trash2 size={16} />
      </button>
    </div>
  );
}

createRoot(document.getElementById("root")).render(<App />);
