import { useState } from 'react'
import './App.css'

function App() {
  const [input, setInput] = useState('')
  const [output, setOutput] = useState('')
  const [loading, setLoading] = useState(false)
  const [wordCount, setWordCount] = useState(10)

  const handleGenerate = async () => {
    if (!input.trim()) {
      alert('Please enter some text')
      return
    }

    setLoading(true)
    try {
      const apiUrl = 'http://localhost:5000'
      const response = await fetch(`${apiUrl}/generate`, {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          seed_text: input,
          n_words: wordCount
        })
      })
      
      const data = await response.json()
      if (data.generated_text) {
        setOutput(data.generated_text)
      } else {
        setOutput('Error generating text')
      }
    } catch (error) {
      console.error('Error:', error)
      setOutput('Failed to connect to server')
    }
    setLoading(false)
  }

  const handleClear = () => {
    setInput('')
    setOutput('')
  }

  const handleCopy = () => {
    navigator.clipboard.writeText(output)
    alert('Copied to clipboard!')
  }

  return (
    <div className='app-container'>
      <div className='background-elements'>
        <div className='gradient-sphere gradient-1'></div>
        <div className='gradient-sphere gradient-2'></div>
        <div className='gradient-sphere gradient-3'></div>
        
      </div>

      <div className='content'>
        <div className='header-section'>
          <h1 className='sparkle'>✨</h1>
          <h1 className='header'>  Text Generation</h1>
          <p className='subtitle'>Write what your heart says, let AI complete your thoughts</p>
        </div>
<div className='info-section'>
          <p className='info-text'>🤖 Powered by LSTM Neural Network</p>
        </div>

        <div className='card main-card'>
          <div className='input-section'>
            <label className='label'>Start your text here</label>
            <textarea
              className='input-box'
              placeholder='Type your seed text here... e.g., "The future is..."'
              value={input}
              onChange={(e) => setInput(e.target.value)}
              rows='4'
            />
          </div>

          <div className='controls-section'>
            <div className='control-group'>
              <label className='label'>Words to generate</label>
              <input
                type='number'
                className='number-input'
                min='1'
                max='50'
                value={wordCount}
                onChange={(e) => setWordCount(Math.max(1, Math.min(50, parseInt(e.target.value) || 1)))}
              />
            </div>
          </div>

          <div className='button-group'>
            <button
              className='btn btn-generate'
              onClick={handleGenerate}
              disabled={loading}
            >
              {loading ? '⏳ Generating...' : '🚀 Generate Text'}
            </button>
            <button className='btn btn-clear' onClick={handleClear}>
              🔄 Clear
            </button>
          </div>
        </div>

        {output && (
          <div className='card output-card'>
            <div className='output-header'>
              <h2 className='output-label'>Generated Text</h2>
              <button className='btn btn-copy' onClick={handleCopy}>
                📋 Copy
              </button>
            </div>
            <p className='output-box'>{output}</p>
          </div>
        )}

        
      </div>
    </div>
  )
}

export default App
