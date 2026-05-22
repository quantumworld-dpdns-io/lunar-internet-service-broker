"""AI agent for automated brokerage operations."""

from typing import Any


class BrokerAgent:
    """Autonomous agent for broker marketplace operations."""

    def __init__(self):
        self.memory: list[dict[str, Any]] = []
        self.tools: dict[str, callable] = {}

    def register_tool(self, name: str, func: callable, description: str) -> None:
        """Register a tool the agent can use."""
        self.tools[name] = {"func": func, "description": description}

    async def process_query(self, query: str) -> str:
        """Process a natural language query about the marketplace."""
        self.memory.append({"role": "user", "content": query})

        # Match against available tools
        for name, tool in self.tools.items():
            if name in query.lower():
                result = tool["func"](query)
                return f"Used tool '{name}': {result}"

        return "I understand your query but need more information to help."

    def get_memory(self) -> list[dict[str, Any]]:
        return self.memory
