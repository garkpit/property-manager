import { toast } from "svelte-sonner";

type ToastType = 'default' | 'success' | 'error' | 'info' | 'warning';

interface ToastOptions {
    description?: string;
    type?: ToastType;
    actionLabel?: string;
    onAction?: () => void;
}

export function showToast(message: string, options: ToastOptions = {}) {
    const { description, type = 'default', actionLabel, onAction } = options;
    const toastOptions: any = {
        description,
    };

    if (actionLabel && onAction) {
        toastOptions.action = {
            label: actionLabel,
            onClick: onAction
        };
    }
    switch (type) {
        case 'success':
            toast.success(message, toastOptions);
            break;
        case 'error':
            toast.error(message, toastOptions);
            break;
        case 'info':
            toast.info(message, toastOptions);
            break;
        case 'warning':
            toast.warning(message, toastOptions);
            break;
        default:
            toast(message, toastOptions);
    }
}
