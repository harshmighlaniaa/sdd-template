"""Base agent class for all specialized agents."""

from abc import ABC, abstractmethod
from typing import Any, Dict
from dataclasses import dataclass, field
from datetime import datetime


@dataclass
class AgentContext:
    """Context passed between agents in the orchestration pipeline."""
    jira_extract: Dict[str, Any] = field(default_factory=dict)
    documentation: Dict[str, Any] = field(default_factory=dict)
    swagger_spec: Dict[str, Any] = field(default_factory=dict)
    skeleton_generated: Dict[str, Any] = field(default_factory=dict)
    metadata: Dict[str, Any] = field(default_factory=dict)
    
    def __post_init__(self):
        if 'created_at' not in self.metadata:
            self.metadata['created_at'] = datetime.now().isoformat()


class BaseAgent(ABC):
    """Abstract base class for all agents."""
    
    def __init__(self, name: str, description: str):
        self.name = name
        self.description = description
        self.logger = self._setup_logger()
    
    def _setup_logger(self):
        """Setup logger for the agent."""
        import logging
        logger = logging.getLogger(self.name)
        if not logger.handlers:
            handler = logging.StreamHandler()
            formatter = logging.Formatter(
                f'[{self.name}] %(asctime)s - %(levelname)s - %(message)s'
            )
            handler.setFormatter(formatter)
            logger.addHandler(handler)
            logger.setLevel(logging.INFO)
        return logger
    
    @abstractmethod
    def execute(self, context: AgentContext) -> AgentContext:
        """
        Execute the agent's task.
        
        Args:
            context: The shared context containing data from previous agents
            
        Returns:
            Updated context with agent's output
        """
        pass
    
    def validate_input(self, context: AgentContext) -> bool:
        """
        Validate that the context has required input for this agent.
        Override in subclasses to implement specific validation.
        
        Args:
            context: The context to validate
            
        Returns:
            True if valid, False otherwise
        """
        return True
    
    def log_start(self):
        """Log agent execution start."""
        self.logger.info(f"Starting execution of {self.description}")
    
    def log_end(self):
        """Log agent execution end."""
        self.logger.info(f"Completed execution")
    
    def log_error(self, error: Exception):
        """Log agent execution error."""
        self.logger.error(f"Error during execution: {str(error)}", exc_info=True)
