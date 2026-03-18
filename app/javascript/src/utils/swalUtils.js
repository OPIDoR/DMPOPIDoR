const defaultConfirmConfig = (t) => ({
  title: t('confirm'),
  text: t('confirmDeleteItem'),
  icon: 'warning',
  showCancelButton: true,
  confirmButtonColor: '#2c7dad',
  cancelButtonColor: '#c6503d',
  cancelButtonText: t('Cancel'),
  confirmButtonText: t('Yes'),
});

const defaultDeleteErrorConfig = (t, recordName) => ({
  title: t('deleteError'),
  message: t('deleteRecordError', { record: t(recordName) }),
  icon: 'error',
});

export default {
  defaultConfirmConfig,
  defaultDeleteErrorConfig,
};
