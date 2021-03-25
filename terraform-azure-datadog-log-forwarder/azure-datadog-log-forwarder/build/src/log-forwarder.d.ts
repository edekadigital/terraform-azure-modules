export interface Rule {
    pattern: string;
    replacement: string;
}
export interface Config {
    name: string;
    rule: Rule;
}
export interface RecordMessage {
    resourceId: string;
}
export interface Metadata {
    tags: string[];
    source: string;
}
