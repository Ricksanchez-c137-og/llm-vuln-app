export async function chatWithAIStream(input: string, onChunk: (chunk: string) => void, onDone: () => void) {
    try {
      const response = await fetch("/api/chat", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({ input }),
      })
  
      if (!response.ok) {
        throw new Error("Network response was not ok")
      }
  
      const reader = response.body?.getReader()
      if (!reader) {
        throw new Error("Failed to get response reader")
      }
  
      while (true) {
        const { done, value } = await reader.read()
        if (done) {
          onDone()
          break
        }
        const chunk = new TextDecoder().decode(value)
        onChunk(chunk)
      }
    } catch (error) {
      console.error("Error:", error)
      onChunk("An error occurred while processing your request.")
      onDone()
    }
  }
  
  