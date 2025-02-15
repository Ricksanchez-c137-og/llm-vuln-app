import ChatComponent from "@/components/ChatComponent"

export default function Home() {
  return (
    <div className="flex flex-col items-center justify-center">
      <h1 className="text-3xl font-bold mb-8">Hosn Chat</h1>
      <ChatComponent />
    </div>
  )
}

