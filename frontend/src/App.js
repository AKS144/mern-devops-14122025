import React, { useState, useEffect } from 'react';
import axios from 'axios';

function App() {
  const [tasks, setTasks] = useState([]);
  const [name, setName] = useState('');
  const [editId, setEditId] = useState(null);
  const [editName, setEditName] = useState('');

  // --- FIX START ---
  // The ingress sends "/api" to the backend. 
  // The backend expects "/tasks".
  // So we simply point to "/api" here, and let the functions add "/tasks".
  const API_URL = '/api'; 
  // const API_URL = "http://localhost:5000";

  // --- FIX END ---

  useEffect(() => { fetchTasks(); }, []);

  const fetchTasks = async () => {
    try {
      // This results in request to: /api/tasks
      const res = await axios.get(`${API_URL}/tasks`);
      // Ensure we only set tasks if we got an array
      if (Array.isArray(res.data)) {
        setTasks(res.data);
      } else {
        console.error("API did not return an array:", res.data);
        setTasks([]); 
      }
    } catch (err) {
      console.error(err);
    }
  };

  const addTask = async () => {
    if (!name.trim()) return;
    try {
      await axios.post(`${API_URL}/tasks`, { name });
      setName('');
      fetchTasks();
    } catch (err) { console.error(err); }
  };

  const deleteTask = async (id) => {
    try {
      await axios.delete(`${API_URL}/tasks/${id}`);
      fetchTasks();
    } catch (err) { console.error(err); }
  };

  const updateTask = async () => {
    if (!editName.trim()) return;
    try {
      await axios.put(`${API_URL}/tasks/${editId}`, { name: editName });
      setEditId(null);
      setEditName('');
      fetchTasks();
    } catch (err) { console.error(err); }
  };

  return (
    <div style={{ maxWidth: "600px", margin: "40px auto", padding: "20px", fontFamily: "Arial", border: "1px solid #ddd", borderRadius: "12px", boxShadow: "0 3px 10px rgba(0,0,0,0.1)" }}>
      <h2 style={{ textAlign: "center" }}>MERN CRUD App</h2>

      {/* ADD FORM */}
      <div style={{ display: "flex", gap: "10px", marginBottom: "20px" }}>
        <input 
          value={name}
          onChange={e => setName(e.target.value)}
          placeholder="Enter task"
          style={{ flex: 1, padding: "10px", borderRadius: "6px", border: "1px solid #aaa" }}
        />
        <button onClick={addTask} style={{ padding: "10px 20px", background: "green", color: "white", border: "none", borderRadius: "6px", cursor: "pointer" }}>Add</button>
      </div>

      {/* TASK LIST */}
      <ul style={{ listStyle: "none", padding: 0 }}>
        {tasks.map(task => (
          <li key={task._id} style={{ padding: "12px", marginBottom: "10px", border: "1px solid #ddd", borderRadius: "8px", display: "flex", justifyContent: "space-between", alignItems: "center" }}>
            {editId === task._id ? (
              <input value={editName} onChange={(e) => setEditName(e.target.value)} style={{ flex: 1, marginRight: "10px", padding: "8px", borderRadius: "6px", border: "1px solid #aaa" }} />
            ) : (
              <span>{task.name}</span>
            )}

            <div style={{ display: "flex", gap: "10px" }}>
              {editId === task._id ? (
                <button onClick={updateTask} style={{ padding: "6px 14px", background: "blue", color: "white", border: "none", borderRadius: "6px", cursor: "pointer" }}>Save</button>
              ) : (
                <button onClick={() => { setEditId(task._id); setEditName(task.name); }} style={{ padding: "6px 14px", background: "orange", color: "white", border: "none", borderRadius: "6px", cursor: "pointer" }}>Edit</button>
              )}
              <button onClick={() => deleteTask(task._id)} style={{ padding: "6px 14px", background: "red", color: "white", border: "none", borderRadius: "6px", cursor: "pointer" }}>Delete</button>
            </div>
          </li>
        ))}
      </ul>
    </div>
  );
}
export default App;