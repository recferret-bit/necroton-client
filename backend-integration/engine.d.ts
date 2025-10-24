/**
 * TypeScript definitions for NecrotonEngine
 * Generated from Haxe source for Node.js backend integration
 */

// Import the actual engine module
import * as engineModule from './engine';

// Export the engine namespace
export const engine = engineModule.engine;

// Main NecrotonEngine class
export class NecrotonEngine {
  static Config: EngineConfig;
  static create(config: EngineConfig): NecrotonEngine;
  static main(): void;
  
  start(): void;
  stop(): void;
  stopSimulation(): void;
  step(dt: number): void;
  queueInput(input: InputMessage): void;
  spawnEntity(spec: EngineEntitySpec): number;
  despawnEntity(entityId: number): void;
  subscribeEvent<T>(topic: string, handler: (payload: T) => void): number;
  subscribeEventDynamic(topic: string, handler: (payload: any) => void): number;
  unsubscribeEvent(token: number): void;
  getSnapshot(): GameStateMemento;
  getEventBus(): IEventBus;
  getCurrentTick(): number;
  rollbackAndReplay(anchorTick: number, pendingInputs: InputMessage[]): void;
  stepFixed(): void;
}

// Event constants for the event bus (these are not exported by Haxe, so we define them separately)
export const EventBusConstants = {
  // Entity events
  ENTITY_SPAWN: "entity:spawn",
  ENTITY_DEATH: "entity:death", 
  ENTITY_MOVE: "entity:move",
  ENTITY_CORRECTION: "entity:correction",
  ENTITY_DAMAGE: "entity:damage",
  ENTITY_COLLISION: "entity:collision",
  
  // Tick events
  TICK_COMPLETE: "tick:complete",
  
  // Snapshot events
  SNAPSHOT: "snapshot",
  
  // Physics events
  PHYSICS_CONTACT: "physics:contact",
  
  // Collider events
  COLLIDER_TRIGGER: "collider:trigger",
  
  // Action events
  ACTION_INTENT: "action:intent",
  ACTION_RESOLVED: "action:resolved"
} as const;

export type EventBusConstantsType = typeof EventBusConstants;

// Event payload type definitions
export interface EntitySpawnEvent {
  tick: number;
  entityId: number;
  type: EntityType;
  pos: Vec2;
  ownerId: string;
}

export interface EntityMoveEvent {
  tick: number;
  entityId: number;
  pos: Vec2;
  vel: Vec2;
  rotation: number;
}

export interface EntityDamageEvent {
  tick: number;
  entityId: number;
  damage: number;
  attackerId: number;
  newHp: number;
}

export interface EntityDeathEvent {
  tick: number;
  entityId: number;
  killerId: number;
}

export interface EntityCollisionEvent {
  tick: number;
  entityIdA: number;
  entityIdB: number;
  contactPoint: Vec2;
  normal: Vec2;
}

export interface EntityCorrectionEvent {
  tick: number;
  entityId: number;
  correctedPos: Vec2;
  correctedVel: Vec2;
}

export interface ActionIntentEvent {
  tick: number;
  actorId: number;
  actionType: string;
  target: any;
}

export interface ActionResolvedEvent {
  tick: number;
  actorId: number;
  actionType: string;
  result: any;
}

export interface TickCompleteEvent {
  tick: number;
}

export interface SnapshotEvent {
  tick: number;
  serializedState: any;
}

export interface ColliderTriggerEvent {
  tick: number;
  entityId: number;
  colliderId: number;
  triggerPos: Vec2;
}

export interface PhysicsContactEvent {
  tick: number;
  entityIdA: number;
  entityIdB: number;
  contactPoint: Vec2;
  normal: Vec2;
  impulse: number;
}

// Engine configuration types
export interface EngineConfig {
  mode: EngineMode;
  tickRate: number;
  unitPixels: number;
  aiUpdateInterval: number;
  snapshotBufferSize: number;
  rngSeed: number;
  snapshotEmissionInterval: number;
}

export enum EngineMode {
  SINGLEPLAYER = "SINGLEPLAYER",
  SERVER = "SERVER", 
  CLIENT_PREDICTION = "CLIENT_PREDICTION"
}

export enum EntityType {
  CHARACTER = "character",
  CONSUMABLE = "consumable",
  EFFECT = "effect",
  COLLIDER = "collider",
  GENERIC = "generic"
}

// Vector2 type
export interface Vec2 {
  x: number;
  y: number;
}

// Entity specification for spawning
export interface EngineEntitySpec {
  id?: number;
  type?: EntityType;
  pos: Vec2;
  vel?: Vec2;
  rotation?: number;
  ownerId: string;
  isAlive?: boolean;
  isInputDriven?: boolean;
  colliderWidth?: number;
  colliderHeight?: number;
  // Character fields
  maxHp?: number;
  hp?: number;
  level?: number;
  stats?: {
    power: number;
    armor: number;
    speed: number;
    castSpeed: number;
  };
  attackDefs?: any[];
  spellBook?: any[];
  aiProfile?: string;
  // Consumable fields
  effectId?: string;
  durationTicks?: number;
  stackable?: boolean;
  charges?: number;
  useRange?: number;
  consumableType?: string;
  quantity?: number;
  effectValue?: any;
  // Effect fields
  effectType?: string;
  intensity?: number;
  targetId?: number;
  casterId?: number;
  duration?: number;
  // Collider fields
  passable?: boolean;
  isTrigger?: boolean;
}

// Input message structure
export interface InputMessage {
  clientId: string;
  sequence: number;
  clientTick: number;
  intendedServerTick: number;
  movement: Vec2;
  actions: any[];
  timestamp: number;
}

// Event bus interface
export interface IEventBus {
  subscribe<T>(topic: string, handler: (payload: T) => void): number;
  subscribeDynamic(topic: string, handler: (payload: any) => void): number;
  unsubscribe(token: number): void;
  emit(topic: string, payload: any): void;
}

// Game state memento
export interface GameStateMemento {
  tick: number;
  entities: any[];
  [key: string]: any;
}

// Main NecrotonEngine class
export declare class NecrotonEngine {

  static engine: {
      create: (config: EngineConfig) => NecrotonEngine;
  }

  static Config: EngineConfig;
  
  /**
   * Create new engine instance
   * @param config Engine configuration
   * @return Engine instance
   */
  static create(config: EngineConfig): NecrotonEngine;
  
  /**
   * Start the engine
   */
  start(): void;
  
  /**
   * Stop the engine
   */
  stop(): void;
  
  /**
   * Stop simulation (alias for stop)
   */
  stopSimulation(): void;
  
  /**
   * Step engine simulation
   * @param dt Delta time
   */
  step(dt: number): void;
  
  /**
   * Queue input from client
   * @param input Input message
   */
  queueInput(input: InputMessage): void;
  
  /**
   * Spawn entity
   * @param spec Entity specification
   * @return Entity ID
   */
  spawnEntity(spec: EngineEntitySpec): number;
  
  /**
   * Despawn entity
   * @param entityId Entity ID
   */
  despawnEntity(entityId: number): void;
  
  /**
   * Subscribe to events with typed handler
   * @param topic Event topic
   * @param handler Event handler
   * @return Subscription token
   */
  subscribeEvent<T>(topic: string, handler: (payload: T) => void): number;
  
  /**
   * Subscribe to events with dynamic handler (legacy support)
   * @param topic Event topic
   * @param handler Event handler
   * @return Subscription token
   */
  subscribeEventDynamic(topic: string, handler: (payload: any) => void): number;
  
  /**
   * Unsubscribe from events
   * @param token Subscription token
   */
  unsubscribeEvent(token: number): void;
  
  /**
   * Get current snapshot
   * @return State memento
   */
  getSnapshot(): GameStateMemento;
  
  /**
   * Get event bus for subscribing to events
   * @return Event bus instance
   */
  getEventBus(): IEventBus;
  
  /**
   * Get current engine tick
   * @return Current tick
   */
  getCurrentTick(): number;
  
  /**
   * Rollback and replay for client prediction
   * @param anchorTick Anchor tick for rollback
   * @param pendingInputs Pending inputs to replay
   */
  rollbackAndReplay(anchorTick: number, pendingInputs: InputMessage[]): void;
  
  /**
   * Execute single engine step
   */
  stepFixed(): void;
}
