export interface Label {
    name: string;
    color: string;
    description: string;
}

export interface CategoryConfig {
    topicLabels: Label[];
}

export interface LabelConfig {
    org: string;
    orgWideLabels: Label[];
    protectedLabels: string[];
    categories: Record<string, CategoryConfig>;
}
