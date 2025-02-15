export async function POST(req: Request) {
  const { input } = await req.json();

  const socket = new WebSocket("ws://localhost:8000/ws");

  return new Response(new ReadableStream({
    start(controller) {
      socket.onopen = () => {
        socket.send(input);
      };

      socket.onmessage = (event) => {
        if (event.data === "[END]") {
          socket.close();
          controller.close();
        } else {
          controller.enqueue(event.data);
        }
      };

      socket.onerror = (error) => {
        console.error("WebSocket Error:", error);
        controller.error(error);
      };
    }
  }));
}
