"use client";

import { useState } from "react";

export default function ChatComponent() {
  const [input, setInput] = useState("");
  const [response, setResponse] = useState("");
  const [isStreaming, setIsStreaming] = useState(false);

  const handleSubmit = (e: { preventDefault: () => void; }) => {
    e.preventDefault();
    setResponse("");
    setIsStreaming(true);

    const socket = new WebSocket("ws://localhost:8000/ws");

    socket.onopen = () => {
      const payload = {
        prompt: input,      
        model: "mistral"
      };
      socket.send(JSON.stringify(payload));
    };
    socket.onmessage = (event) => {
      if (event.data === "[END]") {
        socket.close();
        setIsStreaming(false);
      } else {
        setResponse((prev) => prev + event.data);
      }
    };
    socket.onerror = (error) => {
      console.error("WebSocket Error:", error);
      setIsStreaming(false);
    };
  };

  return (
    <>
      <form onSubmit={handleSubmit} className="flex gap-2 w-full max-w-2xl mb-8">
        <input
          type="text"
          value={input}
          onChange={(e) => setInput(e.target.value)}
          placeholder="Enter your question"
          className="flex-grow border border-gray-700 rounded p-2 bg-gray-800 text-white"
        />
        <button
          type="submit"
          disabled={isStreaming}
          className="bg-white text-black px-6 py-2 rounded font-semibold hover:bg-gray-200 transition-colors"
        >
          {isStreaming ? "Streaming..." : "Ask"}
        </button>
      </form>

      <div className="w-full max-w-2xl">
        <h2 className="text-xl font-semibold mb-2">Response:</h2>
        <p className="p-4 border border-gray-700 rounded bg-gray-800 min-h-[100px] whitespace-pre-wrap">
          {response || "Response will appear here..."}
        </p>
      </div>
    </>
  );
}
