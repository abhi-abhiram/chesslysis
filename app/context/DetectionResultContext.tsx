import * as React from 'react';
import { PredictResult } from '../../modules/ml-module';

export type DetectionResultContextType = {
  result: PredictResult | null;
  setResult: (result: PredictResult | null) => void;
};

export const DetectionResultContext =
  React.createContext<DetectionResultContextType>({
    result: null,
    setResult: () => {},
  });

export const DetectionResultProvider = ({
  children,
}: {
  children: React.ReactNode;
}) => {
  const [result, setResult] = React.useState<PredictResult | null>(null);

  return (
    <DetectionResultContext.Provider value={{ result, setResult }}>
      {children}
    </DetectionResultContext.Provider>
  );
};

export const useDetectionResult = () =>
  React.useContext(DetectionResultContext);
